import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const endpointLocal = process.env.DYNAMODB_ENDPOINT?.trim();

const regionPrincipal =
  process.env.DYNAMODB_REGION_PRINCIPAL?.trim() ||
  process.env.AWS_REGION ||
  "us-east-1";

const regionRespaldo =
  process.env.DYNAMODB_REGION_RESPALDO?.trim() ||
  "us-west-2";

const DURACION_FAILOVER_MS = 60_000;

let usarRespaldoHasta = 0;

function crearCliente(
  region: string,
  endpoint?: string,
): DynamoDBDocumentClient {
  const cliente = new DynamoDBClient({
    region,
    maxAttempts: endpoint ? 3 : 1,

    ...(endpoint
      ? {
          endpoint,
          credentials: {
            accessKeyId: "local",
            secretAccessKey: "local",
          },
        }
      : {}),
  });

  return DynamoDBDocumentClient.from(cliente, {
    marshallOptions: {
      removeUndefinedValues: true,
    },
  });
}

const clienteLocal = endpointLocal
  ? crearCliente(regionPrincipal, endpointLocal)
  : null;

const clientePrincipal = endpointLocal
  ? null
  : crearCliente(regionPrincipal);

const clienteRespaldo = endpointLocal
  ? null
  : crearCliente(regionRespaldo);

function nombreError(error: unknown): string {
  if (error instanceof Error) {
    return error.name;
  }

  return "Error";
}

function codigoError(
  error: unknown,
): string | undefined {
  if (
    typeof error === "object" &&
    error !== null &&
    "code" in error
  ) {
    const codigo = (error as { code?: unknown }).code;

    return typeof codigo === "string"
      ? codigo
      : undefined;
  }

  return undefined;
}

function statusHttp(
  error: unknown,
): number | undefined {
  if (
    typeof error !== "object" ||
    error === null
  ) {
    return undefined;
  }

  return (
    error as {
      $metadata?: {
        httpStatusCode?: number;
      };
    }
  ).$metadata?.httpStatusCode;
}

function debeHacerFailover(
  error: unknown,
): boolean {
  const nombre = nombreError(error);

  const erroresPermitidos = new Set([
    "ResourceNotFoundException",
    "InternalServerError",
    "InternalServerErrorException",
    "ServiceUnavailable",
    "ServiceUnavailableException",
    "RequestTimeout",
    "RequestTimeoutException",
    "TimeoutError",
  ]);

  if (erroresPermitidos.has(nombre)) {
    return true;
  }

  const codigo = codigoError(error);

  if (
    codigo &&
    [
      "ECONNRESET",
      "ETIMEDOUT",
      "ENETUNREACH",
      "EHOSTUNREACH",
      "ECONNREFUSED",
      "ENOTFOUND",
      "EAI_AGAIN",
    ].includes(codigo)
  ) {
    return true;
  }

  const status = statusHttp(error);

  return status !== undefined && status >= 500;
}

function clonarComando(comando: any): any {
  return new comando.constructor(comando.input);
}

async function enviarConFailover(
  comando: any,
): Promise<any> {
  /*
   * En desarrollo local conservamos exactamente
   * el comportamiento anterior.
   */
  if (clienteLocal) {
    return clienteLocal.send(comando);
  }

  if (!clientePrincipal || !clienteRespaldo) {
    throw new Error(
      "No se pudieron inicializar los clientes DynamoDB",
    );
  }

  /*
   * Si hace poco falló Virginia, evitamos probarla
   * en cada petición durante 60 segundos.
   */
  if (Date.now() < usarRespaldoHasta) {
    console.warn(
      `[DynamoDB Failover] Usando réplica ${regionRespaldo}.`,
    );

    return clienteRespaldo.send(
      clonarComando(comando),
    );
  }

  try {
    /*
     * Solo para comprobar el failover sin borrar
     * ninguna réplica real.
     */
    if (
      process.env.SIMULAR_FALLO_DYNAMODB_PRINCIPAL === "true"
    ) {
      const errorSimulado = new Error(
        "Fallo simulado de la réplica principal",
      );

      errorSimulado.name =
        "ResourceNotFoundException";

      throw errorSimulado;
    }

    return await clientePrincipal.send(comando);
  } catch (error) {
    if (!debeHacerFailover(error)) {
      throw error;
    }

    if (regionPrincipal === regionRespaldo) {
      throw error;
    }

    console.warn(
      `[DynamoDB Failover] ${regionPrincipal} falló (${nombreError(
        error,
      )}). Intentando ${regionRespaldo}.`,
    );

    usarRespaldoHasta =
      Date.now() + DURACION_FAILOVER_MS;

    try {
      const resultado =
        await clienteRespaldo.send(
          clonarComando(comando),
        );

      console.warn(
        `[DynamoDB Failover] Operación completada en ${regionRespaldo}.`,
      );

      return resultado;
    } catch (errorRespaldo) {
      console.error(
        `[DynamoDB Failover] También falló ${regionRespaldo}.`,
        errorRespaldo,
      );

      throw errorRespaldo;
    }
  }
}

/*
 * El Proxy es importante:
 *
 * Hacia TypeScript sigue siendo un DynamoDBDocumentClient real,
 * por lo que GetCommand, QueryCommand, UpdateCommand, etc.
 * conservan sus tipos de respuesta.
 *
 * En ejecución interceptamos solamente send() para hacer failover.
 */
const clienteBase =
  clienteLocal || clientePrincipal;

if (!clienteBase) {
  throw new Error(
    "No fue posible crear el cliente DynamoDB",
  );
}

export const baseDatos =
  new Proxy(clienteBase, {
    get(target, propiedad, receptor) {
      if (propiedad === "send") {
        return (
          comando: Parameters<
            DynamoDBDocumentClient["send"]
          >[0],
        ) => enviarConFailover(comando);
      }

      const valor = Reflect.get(
        target,
        propiedad,
        receptor,
      );

      if (typeof valor === "function") {
        return valor.bind(target);
      }

      return valor;
    },
  }) as DynamoDBDocumentClient;

export function nombreTabla(): string {
  const nombre = process.env.NOMBRE_TABLA;

  if (!nombre) {
    throw new Error(
      "Falta la variable de entorno NOMBRE_TABLA",
    );
  }

  return nombre;
}

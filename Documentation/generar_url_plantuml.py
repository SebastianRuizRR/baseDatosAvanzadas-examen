"""
Genera la URL del servidor PlantUML para renderizar el diagrama de despliegue.
Uso: python3 Documentation/generar_url_plantuml.py
Luego abre la URL en el navegador y guarda la imagen.
"""
import zlib
import sys
from pathlib import Path

# Alfabeto propio de PlantUML (64 caracteres)
_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_"

def _enc6(b: int) -> str:
    return _CHARS[b & 0x3F]

def _enc3(b1: int, b2: int, b3: int) -> str:
    return (
        _enc6(b1 >> 2)
        + _enc6(((b1 & 0x3) << 4) | (b2 >> 4))
        + _enc6(((b2 & 0xF) << 2) | (b3 >> 6))
        + _enc6(b3 & 0x3F)
    )

def plantuml_encode(data: bytes) -> str:
    # DEFLATE raw (sin cabecera zlib): stripping 2 bytes de header y 4 de checksum
    compressed = zlib.compress(data, 9)[2:-4]
    result = []
    for i in range(0, len(compressed), 3):
        chunk = compressed[i:i+3]
        b = list(chunk) + [0] * (3 - len(chunk))
        result.append(_enc3(b[0], b[1], b[2]))
    return "".join(result)

def main():
    puml_path = Path(__file__).parent / "diagrama-despliegue.puml"
    if not puml_path.exists():
        print(f"ERROR: No se encontró {puml_path}", file=sys.stderr)
        sys.exit(1)

    content = puml_path.read_text(encoding="utf-8")
    encoded = plantuml_encode(content.encode("utf-8"))

    base = "https://www.plantuml.com/plantuml"
    print("\n=== URLs para el diagrama de despliegue ===\n")
    print(f"PNG  (para PPT):  {base}/png/~1{encoded}\n")
    print(f"SVG  (vectorial): {base}/svg/~1{encoded}\n")
    print(f"Editor online:    {base}/uml/~1{encoded}\n")
    print("Abre cualquiera de estas URLs en el navegador.")
    print("Para PNG: clic derecho → Guardar imagen como → diagrama-despliegue.png\n")

if __name__ == "__main__":
    main()

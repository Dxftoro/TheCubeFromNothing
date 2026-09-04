import math

STEPS = 32
AMPLITUDE = 100

values = []
for i in range(STEPS):
    angle = 2 * math.pi * i / STEPS
    val = round(math.sin(angle) * AMPLITUDE)

    if val < 0:
        val += 256
    values.append(val)

print("sin_table db " + ",".join(f"0x{v:02X}" for v in values))
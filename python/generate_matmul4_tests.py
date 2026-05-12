import numpy as np

NUM_TESTS = 10
DATA_LOW = -8
DATA_HIGH = 8

def main():
    rng = np.random.default_rng(seed=42)

    with open("python/matmul4_tests.txt", "w") as f:
        for test_id in range(NUM_TESTS):
            A = rng.integers(DATA_LOW, DATA_HIGH, size=(4, 4), dtype=np.int8)
            B = rng.integers(DATA_LOW, DATA_HIGH, size=(4, 4), dtype=np.int8)
            C = A.astype(np.int32) @ B.astype(np.int32)

            f.write(f"TEST {test_id}\n")
            f.write("A\n")
            for row in A:
                f.write(" ".join(str(int(x)) for x in row) + "\n")

            f.write("B\n")
            for row in B:
                f.write(" ".join(str(int(x)) for x in row) + "\n")

            f.write("C\n")
            for row in C:
                f.write(" ".join(str(int(x)) for x in row) + "\n")

            f.write("\n")

    print(f"Generated {NUM_TESTS} randomized 4x4 matrix multiplication tests")
    print("Wrote python/matmul4_tests.txt")

if __name__ == "__main__":
    main()

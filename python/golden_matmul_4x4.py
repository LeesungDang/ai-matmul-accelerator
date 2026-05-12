import numpy as np

def matmul_4x4(a, b):
    return a.astype(np.int32) @ b.astype(np.int32)

if __name__ == "__main__":
    a = np.array([
        [1,  2,  3,  4],
        [5,  6,  7,  8],
        [9,  10, 11, 12],
        [13, 14, 15, 16]
    ], dtype=np.int8)

    b = np.array([
        [17, 18, 19, 20],
        [21, 22, 23, 24],
        [25, 26, 27, 28],
        [29, 30, 31, 32]
    ], dtype=np.int8)

    c = matmul_4x4(a, b)

    expected = np.array([
        [250, 260, 270, 280],
        [618, 644, 670, 696],
        [986, 1028, 1070, 1112],
        [1354, 1412, 1470, 1528]
    ], dtype=np.int32)

    print("A =")
    print(a)
    print("B =")
    print(b)
    print("C = A @ B")
    print(c)

    assert np.array_equal(c, expected)
    print("PYTHON 4x4 MATMUL GOLDEN MODEL PASSED")

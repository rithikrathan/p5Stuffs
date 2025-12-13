import random

rows = 84
cols = 48
cellSize = 10
showGrid = True

currGen = []


def neighbourCount(cellx, celly):
    global currGen
    sum = 0

    # (-1,1)    (0, 1)   (1,1)
    # (-1,0)    (0, 0)   (1,0)
    # (-1,-1)  (0, -1)  (1,-1)

    for i in (-1, 0, 1):
        for j in (-1, 0, 1):
            sum += currGen[(cellx + i) % rows][(celly - j) % cols]

    sum -= currGen[cellx][celly]

    return sum


def setup():
    global currGen
    size(840, 480)
    currGen = [[0] * cols for _ in range(rows)]

    # for i in range(0, rows):
    #     for j in range(0, cols):
    #         currGen[i][j] = random.randint(0, 1)

    list = [(40, 20), (41, 20), (41, 24), (43, 21),
            (44, 20), (45, 20), (46, 20)]

    for x, y in list:
        currGen[x][y] = 1


def draw():
    global currGen
    nextGen = [[0]*cols for _ in range(rows)]

    for i in range(0, rows):
        for j in range(0, cols):
            if currGen[i][j]:
                fill(255, 255, 255)
            else:
                fill(0, 0, 0)
            stroke(100)
            square(i * cellSize, j * cellSize, cellSize)

            # actual logic for the game of life
            count = neighbourCount(i, j)
            if currGen[i][j]:
                if count in (2, 3):  # survives
                    nextGen[i][j] = currGen[i][j]
                elif count < 2:  # dies of underpopulation
                    nextGen[i][j] = 0
                elif count > 3:  # dies of overpopulation
                    nextGen[i][j] = 0
            else:
                if count == 3:
                    nextGen[i][j] = 1  # birth by reproduction

    currGen = nextGen

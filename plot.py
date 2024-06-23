import matplotlib.pyplot as plt
import matplotlib.patches as patches

byte_per_val = 4
# Initialize min and max memory addresses
min_point = 23702854340464

# Create a figure and axis
fig, ax = plt.subplots(figsize=(15, 8))

x_max = 1024
y_max = 1024
x_width = 1
y_width = 1
ax.set_xlim(0, x_max+x_width)
ax.set_ylim(0, y_max+y_width)


class Point:
    def __init__(self, pos, color):
        self.pos = pos
        self.color = color


class Entry:
    # Assumes the fields in this order
    # layer, trans_a, trans_b, trans_c, contig_a, contig_b, contig_c
    # m, n, k, alpha, a, lda, b, ldb, beta, c, ldc
    def __init__(self, fields):
        if (len(fields) != 18):
            raise ValueError("fields has invalid entries")
        self.layer = int(fields[0])
        self.trans_a = fields[1]
        self.trans_b = fields[2]
        self.trans_c = fields[3]
        self.contig_a = int(fields[4])
        self.contig_b = int(fields[5])
        self.contig_c = int(fields[6])
        self.m = int(fields[7])
        self.n = int(fields[8])
        self.k = int(fields[9])
        self.alpha = int(fields[10])
        self.a = int(fields[11], 16) // byte_per_val
        self.lda = int(fields[12])
        self.b = int(fields[13], 16) // byte_per_val
        self.ldb = int(fields[14])
        self.beta = int(fields[15])
        self.c = int(fields[16], 16) // byte_per_val
        self.ldc = int(fields[17])
        if (min(self.a, self.b, self.c) < min_point):
            raise ValueError("Min address violated")
        self.a = self.a - min_point
        self.b = self.b - min_point
        self.c = self.c - min_point
        if (self.layer == 0):
            color = 'b'
        elif (self.layer == 1):
            color = 'g'
        elif (self.layer == 2):
            color = 'c'
        else:
            raise ValueError("Unexpected self.layer value")
        self.points_a = self.__ReturnPoints(
            self.a // 4, self.lda,
            (self.k if self.trans_a == "TransposeA" else self.m),
            (self.m if self.trans_a == "TransposeA" else self.k), color)
        if (self.layer == 0):
            color = 'r'
        elif (self.layer == 1):
            color = 'm'
        elif (self.layer == 2):
            color = 'y'
        else:
            raise ValueError("Unexpected layer value")
        self.points_b = self.__ReturnPoints(
            self.b // 4, self.ldb,
            (self.n if self.trans_b == "TransposeB" else self.k),
            (self.k if self.trans_b == "TransposeB" else self.n), color)
        color = 'k'
        self.points_c = self.__ReturnPoints(
            self.c // 4, self.ldc, self.m, self.n, color)
        self.points = self.points_a + self.points_b + self.points_c

    def __ReturnPoints(self, begin_point, ld, param1, param2, color):
        retlist = []
        pos = begin_point
        # retlist.append(Point(pos, color))
        for j in range(0, param2):
            for i in range(0, param1):
                retlist.append(Point(pos, color))
                pos += 1
            pos += ld
        return retlist


# Read file
with open('trace', 'r') as f:
    trace = f.readlines()


for entry in trace:
    fields = entry.strip().split()
    curr_entry = Entry(fields)
    for point in curr_entry.points:
        pos = point.pos
        xcoord = pos // y_max
        ycoord = pos % y_max
        sq = patches.Rectangle((xcoord, ycoord), x_width,
                               y_width, fill=True, color=point.color)
        ax.add_patch(sq)
    plt.pause(0.2)

# # Get an array of memory addresses
# addresses = np.random.randint(0, 1000, size=100)


# ax.axis([0, y_max+1, 0, x_max+1])
plt.axis('off')
# plt.grid(b=True, which='major', color='b', linestyle='-')
plt.show()

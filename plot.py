import matplotlib.pyplot as plt
import matplotlib.patches as patches


class Entry:
    # Assumes the fields in this order
    # layer, trans_a, trans_b, trans_c, contig_a, contig_b, contig_c
    # m, n, k, alpha, a, lda, b, ldb, beta, c, ldc
    def __init__(self, fields):
        if (len(fields) != 18):
            raise ValueError("fields has invalid entries")
        self.layer = fields[0]
        self.trans_a = fields[1]
        self.trans_b = fields[2]
        self.trans_c = fields[3]
        self.contig_a = fields[4]
        self.contig_b = fields[5]
        self.contig_c = fields[6]
        self.m = fields[7]
        self.n = fields[8]
        self.k = fields[9]
        self.alpha = fields[10]
        self.a = int(fields[11], 16)
        self.lda = fields[12]
        self.b = int(fields[13], 16)
        self.ldb = fields[14]
        self.beta = fields[15]
        self.c = int(fields[16], 16)
        self.ldc = fields[17]

    def ReturnMempoints(self):
        return [self.a]


# Initialize min and max memory addresses
min_addr = 94811417406272
max_addr = -float('inf')

# Create a figure and axis
fig, ax = plt.subplots(figsize=(30, 8))

y_max = 4096
x_width = 32
y_width = 32


# Read file
with open('trace', 'r') as f:
    trace = f.readlines()


total_addresses = []
for entry in trace:
    fields = entry.strip().split()
    curr_entry = Entry(fields)
    # Generate individual points
    curr_mempoints = curr_entry.ReturnMempoints()
    print(curr_mempoints)

    if (min(curr_mempoints) < min_addr):
        raise ValueError("min_addr violated")
    elif (max(curr_mempoints) > max_addr):
        # Recalculate the range and redraw the past points
        max_addr = max(curr_mempoints)
        addr_range = max_addr - min_addr
        x_max = addr_range // y_max
        ax.clear()
        ax.set_xlim(0, x_max+x_width)
        ax.set_ylim(0, y_max+y_width)
        for addr_entry in total_addresses:
            xcoord = addr_entry // y_max
            ycoord = addr_entry % y_max
            sq = patches.Rectangle(
                (xcoord, ycoord), x_width, y_width, fill=True)
            ax.add_patch(sq)
    # subtract the offset
    curr_mempoints = [point - min_addr for point in curr_mempoints]
    for point in curr_mempoints:
        xcoord = point // y_max
        ycoord = point % y_max
        print(point)
        print(xcoord)
        print(ycoord)
        print(addr_range)
        sq = patches.Rectangle((xcoord, ycoord), x_width, y_width, fill=True)
        ax.add_patch(sq)
    total_addresses.extend(curr_mempoints)
    plt.pause(0.5)

# # Get an array of memory addresses
# addresses = np.random.randint(0, 1000, size=100)


# ax.axis([0, y_max+1, 0, x_max+1])
plt.axis('off')
# plt.grid(b=True, which='major', color='b', linestyle='-')
plt.show()

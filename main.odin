package bbc

import "core:fmt"

main :: proc() {
    init_all()

    parse_fen("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPpP/R3K2R b KQkq - 0 1 ")
    print_board()

    generate_moves()
}

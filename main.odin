package bbc

import "core:fmt"

main :: proc() {
    init_all()

    parse_fen("r3k2r/p2pqpb1/bn2pnp1/2pPN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R b KQkq a3 0 1 ")
    print_board()

    generate_moves()
}

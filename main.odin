package bbc

import "core:fmt"

main :: proc() {
    init_all()


    move := encode_move( 
        get_square(.e2), 
        get_square(.e4),
        N, Q, 0, 0, 1, 0
    )

    source_square := get_move_source(move)
    target_square := get_move_target(move)
    piece := get_move_piece(move)
    promoted_piece := get_move_promoted(move)
    capture := get_move_capture(move)
    double := get_move_double(move)
    enpassant := get_move_enpassant(move)
    castling := get_move_castling(move)

    fmt.printf("source: %s -> target: %s\n", square_to_coordinates[source_square], square_to_coordinates[target_square])
    fmt.printf("piece: %s\n", unicode_pieces[piece])
    fmt.printf("promoted: %s\n", unicode_pieces[promoted_piece])
    fmt.printf("capture flag: %d\n", capture)
    fmt.printf("double flag: %d\n", double)
    fmt.printf("enpassant flag: %d\n", enpassant)
    fmt.printf("castling flag: %d\n", castling)
}

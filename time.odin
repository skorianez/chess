package bbc

import "core:fmt"
import "core:sys/linux"

// TODO: portar para Odin?
get_time_ms :: proc() -> int {
    time_val : linux.Time_Val
    linux.gettimeofday(&time_val)
    return time_val.seconds * 1000 + time_val.microseconds / 1000
}
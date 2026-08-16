/// Native size of PokeAPI's official artwork PNGs. Decoding above this gains
/// nothing, so it caps every `memCache*` value.
const int kArtworkSourcePx = 475;

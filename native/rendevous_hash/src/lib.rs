use rustler::{Encoder, Error};

#[rustler::nif]
fn murmur_hash(input: String) -> u32 {
    murmur3::murmur3_32(&mut input.as_bytes(), 0).unwrap_or(0)
}

#[rustler::nif]
fn sorted_bucket_list<'a>(
    env: rustler::Env<'a>,
    map: rustler::Term<'a>,
    multiplier: i64,
) -> rustler::NifResult<rustler::Term<'a>> {
    use rustler::types::map::MapIterator;

    let map_iter = MapIterator::new(map).ok_or(Error::BadArg)?;

    // Collect all key-value pairs first
    let mut pairs = Vec::new();

    // Process each key-value pair
    for (key, value) in map_iter {
        // Extract the integer value
        let int_value: i64 = value.decode()?;

        // Multiply and keep only the lowest 32 bits
        let new_value = (int_value * multiplier) & 0xFFFFFFFF;

        // Add the transformed pair to the pairs vector
        pairs.push((key, new_value));
    }

    // Sort pairs by the hash value (second element of the tuple)
    pairs.sort_by(|a, b| a.1.cmp(&b.1));

    // Extract just the keys (bucket IDs) in sorted order
    let sorted_keys: Vec<rustler::Term<'a>> = pairs.into_iter().map(|(key, _)| key).collect();

    // Encode the sorted keys as a list
    Ok(sorted_keys.encode(env))
}

rustler::init!("Elixir.RendevousHash.Native");

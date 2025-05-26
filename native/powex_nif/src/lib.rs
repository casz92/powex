use rustler::{Atom, Binary};
use sha2::{Digest, Sha256};
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::Arc;
use std::thread;

mod atoms {
    rustler::atoms! {
        ok,
        error,
        nif_not_loaded
    }
}

/// Computes SHA-256 hash for data + nonce combination
fn compute_hash(data: &[u8], nonce: u64) -> String {
    let mut hasher = Sha256::new();
    hasher.update(data);
    hasher.update(nonce.to_le_bytes());
    let result = hasher.finalize();
    hex::encode(result)
}

/// Checks if hash meets the difficulty requirement (leading zeros)
fn meets_difficulty(hash: &str, difficulty: u32) -> bool {
    if difficulty == 0 {
        return true;
    }

    let required_zeros = difficulty as usize;
    hash.chars().take(required_zeros).all(|c| c == '0')
}

/// Single-threaded Proof of Work computation
#[rustler::nif]
fn compute(data: Binary, difficulty: u32) -> Result<u64, (Atom, &'static str)> {
    let data_bytes = data.as_slice();

    if difficulty > 64 {
        return Err((atoms::error(), "Difficulty too high (max 64)"));
    }

    for nonce in 0..u64::MAX {
        let hash = compute_hash(data_bytes, nonce);
        if meets_difficulty(&hash, difficulty) {
            return Ok(nonce);
        }

        // Prevent infinite loops for very high difficulties
        if nonce > 0 && nonce % 1_000_000 == 0 && difficulty > 20 {
            // For very high difficulties, we might want to give up after some attempts
            if nonce > 100_000_000 {
                return Err((atoms::error(), "Difficulty too high, computation aborted"));
            }
        }
    }

    Err((atoms::error(), "No valid nonce found"))
}

/// Validates if a nonce produces a valid hash for the given difficulty
#[rustler::nif(name = "valid?")]
fn valid(data: Binary, nonce: u64, difficulty: u32) -> bool {
    let data_bytes = data.as_slice();
    let hash = compute_hash(data_bytes, nonce);
    meets_difficulty(&hash, difficulty)
}

/// Parallel Proof of Work computation using multiple threads
#[rustler::nif]
fn compute_parallel(
    data: Binary,
    difficulty: u32,
    num_threads: u32
) -> Result<u64, (Atom, &'static str)> {
    let data_bytes = data.as_slice().to_vec();

    if difficulty > 64 {
        return Err((atoms::error(), "Difficulty too high (max 64)"));
    }

    if num_threads == 0 || num_threads > 64 {
        return Err((atoms::error(), "Invalid number of threads (1-64)"));
    }

    let found = Arc::new(AtomicBool::new(false));
    let result_nonce = Arc::new(AtomicU64::new(0));
    let mut handles = vec![];

    let chunk_size = u64::MAX / num_threads as u64;

    for thread_id in 0..num_threads {
        let data_clone = data_bytes.clone();
        let found_clone = Arc::clone(&found);
        let result_clone = Arc::clone(&result_nonce);

        let start_nonce = thread_id as u64 * chunk_size;
        let end_nonce = if thread_id == num_threads - 1 {
            u64::MAX
        } else {
            (thread_id + 1) as u64 * chunk_size
        };

        let handle = thread::spawn(move || {
            for nonce in start_nonce..end_nonce {
                if found_clone.load(Ordering::Relaxed) {
                    break;
                }

                let hash = compute_hash(&data_clone, nonce);
                if meets_difficulty(&hash, difficulty) {
                    found_clone.store(true, Ordering::Relaxed);
                    result_clone.store(nonce, Ordering::Relaxed);
                    break;
                }

                // Check periodically for very high difficulties
                if nonce > 0 && nonce % 1_000_000 == 0 && difficulty > 20 {
                    if nonce - start_nonce > 100_000_000 {
                        break;
                    }
                }
            }
        });

        handles.push(handle);
    }

    // Wait for all threads to complete
    for handle in handles {
        handle.join().unwrap();
    }

    if found.load(Ordering::Relaxed) {
        Ok(result_nonce.load(Ordering::Relaxed))
    } else {
        Err((atoms::error(), "No valid nonce found"))
    }
}

/// Gets the hash for a given data and nonce combination
#[rustler::nif]
fn get_hash(data: Binary, nonce: u64) -> Result<String, (Atom, &'static str)> {
    let data_bytes = data.as_slice();
    let hash = compute_hash(data_bytes, nonce);
    Ok(hash)
}

rustler::init!("Elixir.Powex");

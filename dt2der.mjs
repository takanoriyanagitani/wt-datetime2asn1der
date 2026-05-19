//@ts-expect-error
import { readFile } from "node:fs/promises";

(async () => {
	/** @type {string} */
	const wasm = "./dt2der.wasm";

	const pbytes = readFile(wasm);
	const pwasm = pbytes.then(WebAssembly.instantiate);

	const { instance } = await pwasm;
	const { exports } = instance;
	const { ymdhms2unpacked, memory } = exports;

  ymdhms2unpacked(
    2026,
    5,
    18,
    23,
    59,
    59,
    9999,
  );

  const buf = Buffer.from(memory.buffer, 0, 25);

  process.stdout.write(buf);

})();

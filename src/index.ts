import { BinaryReader, BinaryWriter, Encoding } from 'csharp-binary-stream';
import { buffer as toBuffer } from 'get-stream';
import JSZip from 'jszip';
import lzma from 'lzma-purejs';

export interface CFLEntry {
  compression: number;
  offset: number;
  length: number;
  size: number;
  name: string;
  hash: string | null;
  contents: ArrayBufferLike;
}

export interface CFLOptions {
  log?: boolean;
}

export async function convert(buffer: ArrayBufferLike, options: CFLOptions = {}): Promise<Buffer> {
  const reader = new BinaryReader(buffer);
  const hashed = reader.readChars(4, Encoding.Utf8) === 'DFL3';
  reader.position = reader.readUnsignedInt();
  const format = reader.readInt();

  if (options.log) console.log('Decoded CFL header.');

  const content = Uint8Array.from(reader.readBytes(reader.readInt()));
  const data = new BinaryReader(format === 4 ? decompress(content) : content);

  const entryPromises = [];
  let position = 0;

  while (data.length > position) {
    const size = data.readInt();
    const offset = data.readInt();
    const compression = data.readInt();
    const name = data.readChars(data.readShort(), Encoding.Utf8);
    const hash = hashed ? data.readChars(data.readInt(), Encoding.Utf8) : null;
    const length = 14 + name.length + (hash ? 4 + hash.length : 0);

    reader.position = offset;
    const entry = Uint8Array.from(reader.readBytes(reader.readUnsignedInt()));
    entryPromises.push(
      Promise.resolve({
        compression,
        contents: compression === 4 ? decompress(entry) : entry,
        hash,
        length,
        name,
        offset,
        size,
      })
    );

    position += length;
  }

  const entries: CFLEntry[] = await Promise.all(entryPromises);
  if (options.log) console.log(`Parsed ${entries.length} entries.`);

  const zip = new JSZip();
  entries.forEach((entry, index) => {
    zip.file(entry.name, entry.contents, { binary: true, compression: 'DEFLATE' });
    if (options.log && index % 10 === 0) console.log(`Processed ${index + 1}/${entries.length} entries...`);
  });

  return toBuffer(zip.generateNodeStream({ type: 'nodebuffer', streamFiles: true }));
}

export function decompress(data: ArrayBufferLike): ArrayBufferLike {
  const input = new Uint8Array(data);
  const reader = new BinaryReader(input);
  const writer = new BinaryWriter();

  // Read the LZMA properties (first 5 bytes of the compressed data)
  const properties = reader.readBytes(5);

  // Use the LZMA library to decompress the data
  lzma.decompress(properties, reader, writer, -1); // -1 means decompress to the end

  // Return the decompressed data as an ArrayBuffer
  return writer.toUint8Array().buffer;
}

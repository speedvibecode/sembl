import type { ProjectBuildFile, ProjectBuildRun } from "./types";

const crcTable = new Uint32Array(256);
for (let index = 0; index < 256; index += 1) {
  let value = index;
  for (let bit = 0; bit < 8; bit += 1) {
    value = value & 1 ? 0xedb88320 ^ (value >>> 1) : value >>> 1;
  }
  crcTable[index] = value >>> 0;
}

function crc32(buffer: Buffer) {
  let value = 0xffffffff;
  for (const byte of buffer) {
    value = crcTable[(value ^ byte) & 0xff] ^ (value >>> 8);
  }
  return (value ^ 0xffffffff) >>> 0;
}

function dosDateTime(date = new Date()) {
  const year = Math.max(1980, date.getFullYear());
  const dosTime =
    (date.getHours() << 11) | (date.getMinutes() << 5) | Math.floor(date.getSeconds() / 2);
  const dosDate =
    ((year - 1980) << 9) | ((date.getMonth() + 1) << 5) | date.getDate();
  return { dosDate, dosTime };
}

function writeLocalHeader(input: {
  name: Buffer;
  crc: number;
  size: number;
  dosDate: number;
  dosTime: number;
}) {
  const header = Buffer.alloc(30);
  header.writeUInt32LE(0x04034b50, 0);
  header.writeUInt16LE(20, 4);
  header.writeUInt16LE(0x0800, 6);
  header.writeUInt16LE(0, 8);
  header.writeUInt16LE(input.dosTime, 10);
  header.writeUInt16LE(input.dosDate, 12);
  header.writeUInt32LE(input.crc, 14);
  header.writeUInt32LE(input.size, 18);
  header.writeUInt32LE(input.size, 22);
  header.writeUInt16LE(input.name.length, 26);
  header.writeUInt16LE(0, 28);
  return Buffer.concat([header, input.name]);
}

function writeCentralHeader(input: {
  name: Buffer;
  crc: number;
  size: number;
  offset: number;
  dosDate: number;
  dosTime: number;
}) {
  const header = Buffer.alloc(46);
  header.writeUInt32LE(0x02014b50, 0);
  header.writeUInt16LE(20, 4);
  header.writeUInt16LE(20, 6);
  header.writeUInt16LE(0x0800, 8);
  header.writeUInt16LE(0, 10);
  header.writeUInt16LE(input.dosTime, 12);
  header.writeUInt16LE(input.dosDate, 14);
  header.writeUInt32LE(input.crc, 16);
  header.writeUInt32LE(input.size, 20);
  header.writeUInt32LE(input.size, 24);
  header.writeUInt16LE(input.name.length, 28);
  header.writeUInt16LE(0, 30);
  header.writeUInt16LE(0, 32);
  header.writeUInt16LE(0, 34);
  header.writeUInt16LE(0, 36);
  header.writeUInt32LE(0, 38);
  header.writeUInt32LE(input.offset, 42);
  return Buffer.concat([header, input.name]);
}

function writeEndOfCentralDirectory(input: {
  fileCount: number;
  centralDirectorySize: number;
  centralDirectoryOffset: number;
}) {
  const end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50, 0);
  end.writeUInt16LE(0, 4);
  end.writeUInt16LE(0, 6);
  end.writeUInt16LE(input.fileCount, 8);
  end.writeUInt16LE(input.fileCount, 10);
  end.writeUInt32LE(input.centralDirectorySize, 12);
  end.writeUInt32LE(input.centralDirectoryOffset, 16);
  end.writeUInt16LE(0, 20);
  return end;
}

export function createBuildArchive(buildRun: ProjectBuildRun, files: ProjectBuildFile[]) {
  const manifest = {
    schema: "sembl.build_artifact.v1",
    build_run: {
      id: buildRun.id,
      project_id: buildRun.project_id,
      graph_version_id: buildRun.graph_version_id,
      status: buildRun.status,
      model: buildRun.model,
      summary: buildRun.summary,
      repository_url: buildRun.repository_url,
      deployment_url: buildRun.deployment_url,
      created_at: buildRun.created_at
    },
    files: files.map((file) => ({
      path: file.path,
      role: file.role,
      language: file.language,
      checksum: file.checksum,
      byte_size: file.byte_size
    }))
  };

  const entries = [
    {
      path: "sembl-build-manifest.json",
      content: JSON.stringify(manifest, null, 2)
    },
    ...files.map((file) => ({
      path: file.path,
      content: file.content
    }))
  ];
  const { dosDate, dosTime } = dosDateTime();
  const localParts: Buffer[] = [];
  const centralParts: Buffer[] = [];
  let offset = 0;

  for (const entry of entries) {
    const name = Buffer.from(entry.path, "utf8");
    const content = Buffer.from(entry.content, "utf8");
    const crc = crc32(content);
    const localHeader = writeLocalHeader({
      name,
      crc,
      size: content.length,
      dosDate,
      dosTime
    });
    const centralHeader = writeCentralHeader({
      name,
      crc,
      size: content.length,
      offset,
      dosDate,
      dosTime
    });

    localParts.push(localHeader, content);
    centralParts.push(centralHeader);
    offset += localHeader.length + content.length;
  }

  const centralDirectory = Buffer.concat(centralParts);
  const end = writeEndOfCentralDirectory({
    fileCount: entries.length,
    centralDirectorySize: centralDirectory.length,
    centralDirectoryOffset: offset
  });

  return Buffer.concat([...localParts, centralDirectory, end]);
}

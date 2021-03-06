#pragma once
#include <core.h>
#include <Stream.h>
#include <FileStream.h>
#include <vector>
#include <set>
#include <map>
#include <string>
#include <memory>

namespace Consolgames
{
class Stream;
}


typedef bool (*PProgrFunc)(int act, int val, char* str);
// if return true then abort


class IPakProgressHandler
{
public:
	virtual void init(int size) = 0;
	virtual void progress(int value, const char* message) = 0;
	virtual void finish() = 0;
	virtual bool stopRequested()
	{
		return false;
	}
};

#pragma pack(push, 1)

struct ResType
{
	ResType()
	{
		id[0] = id[1] = id[2] = id[3] = 0;
	}
	ResType(const char* str)
	{
		id[0] = str[0];
		id[1] = str[1];
		id[2] = str[2];
		id[3] = str[3];
	}
	std::string toString() const
	{
		std::string result(4, '\0');
		result[0] = id[0];
		result[1] = id[1];
		result[2] = id[2];
		result[3] = id[3];
		return result;
	}
	bool operator==(const ResType& r) const
	{
		return id[0] == r.id[0] && id[1] == r.id[1] && id[2] == r.id[2] && id[3] == r.id[3];
	}
	bool operator==(const char* s) const
	{
		return *this == ResType(s);
	}
	bool operator<(const ResType& r) const
	{
		for (int i = 0; i < 4; i++)
		{
			if (id[i] < r.id[i])
			{
				return true;
			}
			if (id[i] > r.id[i])
			{
				return false;
			}
		}
		return false;
	}
	char id[4];
};

typedef unsigned long long Hash;


struct PakHeader
{
	int tag02;
	int tag40;
	Hash hash1;
	Hash hash2;
};

struct SegmentRecord
{
	ResType res;
	unsigned int size;
};

std::string hashToStr(const Hash& hash);
Hash hashFromData(const char* c);

struct FileRecord
{
	int packed;
	ResType res;
	Hash hash;
	unsigned int size;
	unsigned int offset;

	std::string name() const
	{
		return hashToStr(hash) + "." + res.toString();
	}
};

struct CompressedFileHeader
{
	ResType sign;
	int type;

	enum Type
	{
		Normal = 1,
		Texture = 2
	};

	bool isTexture() const
	{
		return (type == Texture);
	}
};

struct CompressedStreamHeader
{
	uint32 flags   : 8;
	uint32 lzoSize : 24;
	uint32 dataSize;
};

#pragma pack(pop)


struct NameRecord
{
	std::string name;
	ResType res;
	Hash hash;
};

class PakArchive
{
public:
	PakArchive();

	bool open(Consolgames::Stream* pak);
	bool open(const std::wstring& filename);

	bool extract(const std::wstring& OutDir, const std::set<ResType>& types = std::set<ResType>(), bool useNames = false);

	//! Rebuilds pak, use files for replace from input directories.
	bool rebuild(Consolgames::Stream* out, const std::vector<std::wstring>& inputDirs,
		const std::set<ResType>& types = std::set<ResType>(),
		const std::map<Hash,Hash>& mergeMap = std::map<Hash,Hash>());

	bool rebuild(const std::wstring& destName, const std::vector<std::wstring>& inputDirs,
		const std::set<ResType>& types = std::set<ResType>(),
		const std::map<Hash,Hash>& mergeMap = std::map<Hash,Hash>());

	bool opened() const;
	int fileCount() const;
	void setProgressHandler(IPakProgressHandler* handler);

	std::vector<Hash> fileNamehashesList() const;
	const std::vector<FileRecord>& files() const;
	bool extractFile(Hash filenameHash, Consolgames::Stream* out);

	Consolgames::Stream* openFileDirect(Hash hash);

	static uint32 compressLzo(Consolgames::Stream* in, int size, Consolgames::Stream *out, void* lzoWorkMem);
	static void decompressLzo(Consolgames::Stream* lzoStream, uint32 lzoSize, Consolgames::Stream* outStream);

protected:
	enum CompressionFlags
	{
		FlagUnknown1   = 1,
		FlagUnknown2   = 1 << 1,
		FlagUnknown3   = 1 << 2,
		FlagUnknown4   = 1 << 3,
		FlagUnknown5   = 1 << 4,
		FlagData       = 1 << 5,
		FlagTexture    = 1 << 6,
		FlagCompressed = 1 << 7
	};

protected:
	CompressedFileHeader readCmpdFileHeader();
	CompressedStreamHeader readCmpdStreamHeader();

	bool extractFile(const FileRecord& file, Consolgames::Stream* out);
	uint32 storeFile(Consolgames::Stream* file, Consolgames::Stream* stream, bool isPacked, bool isTexture, uint8 flags = 0xFF);
	virtual std::wstring findFile(const std::vector<std::wstring>& inputDirs, Hash hash, ResType res) const;
	virtual uint32 storeFile(const std::wstring& filename, Consolgames::Stream* stream, bool isPacked, bool isTexture, uint8 flags = 0xFF);
	int findSegment(ResType type) const;
	int getSegmentOffset(int index) const;
	static void swapFileEndian(FileRecord& fileRecord);
	std::string findName(const Hash& hash) const;
	uint32 compressLzo(Consolgames::Stream* in, int size, Consolgames::Stream *out);

protected:
	void initProgress(int count);
	void progress(int value, const char* message);
	void finishProgress();
	bool stopRequested();


protected:
	static FileRecord* findFileRecord(Hash hash, std::vector<FileRecord>& files);

protected:
	IPakProgressHandler* m_progressHandler;
	
	Consolgames::Stream* m_stream;
	std::auto_ptr<Consolgames::FileStream> m_fileStream;
	
	int m_strgIndex;
	int m_rshdIndex;
	int m_dataIndex;
	uint32 m_strgOffset;
	uint32 m_rshdOffset;
	uint32 m_dataOffset;
	
	std::vector<char> m_lzoWorkMem;
	
	std::vector<SegmentRecord> m_segments;
	PakHeader m_header;
	std::vector<FileRecord> m_files;
	std::vector<NameRecord> m_names;
};

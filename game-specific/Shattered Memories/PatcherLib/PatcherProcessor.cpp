#include "PatcherProcessor.h"
#include "PatcherDirectoriesFileSource.h"
#include "PatcherTexturesFileSource.h"
#include "EmbededResourceInfo.h"
#include "ArchiveProgressNotifier.h"
#include "CheckingProgressNotifier.h"
#include "WiiDiscImage.h"
#include "PS2DiscImage.h"
#include "PSPDiscImage.h"
#include <Archive.h>
#include <PartStream.h>
#include <QtFileStream.h>
#include <WiiFileStream.h>
#include <QTextStream>
#include <QDir>
#include <QSettings>
#include <algorithm>

using namespace Consolgames;
using namespace std;
using namespace tr1;

namespace ShatteredMemories
{

static std::auto_ptr<DiscImage> imageForPlatform(PatcherProcessor::Platform platform)
{
	switch (platform)
	{
	case PatcherProcessor::platformWii:
		return std::auto_ptr<DiscImage>(new WiiDiscImage());
	case PatcherProcessor::platformPS2:
		return std::auto_ptr<DiscImage>(new PS2DiscImage());
	case PatcherProcessor::platformPSP:
		return std::auto_ptr<DiscImage>(new PSPDiscImage());
	}

	ASSERT(!"Invalid platform!");
	return std::auto_ptr<DiscImage>();
}

//////////////////////////////////////////////////////////////////////////

PatcherProcessor::PatcherProcessor()
	: m_errorCode(NoError)
{
}

bool PatcherProcessor::init(const QString& manifestPath)
{
	if (!QFileInfo(manifestPath).exists())
	{
		m_errorCode = Init_UnableToLoadManifest;
		m_errorData = manifestPath;
		return false;
	}

	QSettings manifest(manifestPath, QSettings::IniFormat);

	if (!manifest.contains("platform")
		|| !manifest.contains("game")
		|| !manifest.contains("discId")
		|| !manifest.contains("executablePath")
		|| !manifest.contains("mainArcPath")
		|| !manifest.contains("embededArcOffset")
		|| !manifest.contains("embededArcName"))
	{
		m_errorCode = Init_InvalidManifest;
		return false;
	}

	const QString plarformName = manifest.value("platform").toString();
	if (plarformName == "wii")
	{
		m_info.platform = platformWii;
	}
	else if (plarformName == "ps2")
	{
		m_info.platform = platformPS2;
	}
	else if (plarformName == "psp")
	{
		m_info.platform = platformPSP;
	}
	else
	{
		m_errorCode = Init_InvalidPlatform;
		m_errorData = plarformName;
		return false;
	}

	const QString gameName = manifest.value("game").toString();
	if (gameName == "memories")
	{
		m_info.game = gameShatteredMemories;
	}
	else if (gameName == "origins")
	{
		m_info.game = gameOrigins;
	}
	else
	{
		m_errorCode = Init_InvalidGame;
		m_errorData = gameName;
		return false;
	}

	m_info.discId = manifest.value("discId").toByteArray();
	m_info.executablePath   = manifest.value("executablePath").toString();
	m_info.mainArcPath      = manifest.value("mainArcPath").toString();
	m_info.uiArcContainer   = manifest.value("uiArcContainer").toString();
	m_info.embededArcName   = manifest.value("embededArcName").toString();
	m_info.embededArcOffset = manifest.value("embededArcOffset").toString().toUInt(NULL, 16);
	m_info.headersOffset    = manifest.value("arcHeadersOffset").toString().toUInt(NULL, 16);

	if (m_info.discId.isEmpty() || m_info.executablePath.isEmpty() || m_info.embededArcOffset == 0 || (m_info.game == gameShatteredMemories && m_info.headersOffset == 0))
	{
		m_errorCode = Init_InvalidManifest;
		return false;
	}


	m_exePatcher.reset();

	const QString executablePatchFilename = manifest.value("executablePatch").toString();
	if (!executablePatchFilename.isEmpty())
	{
		QString path = executablePatchFilename;
		if (QFileInfo(executablePatchFilename).isRelative())
		{
			path = QFileInfo(manifestPath).absoluteDir().absoluteFilePath(executablePatchFilename);
		}

		if (!QFileInfo(path).exists())
		{
			m_errorCode = Init_UnableToLoadExecutablePatch;
			m_errorData = executablePatchFilename;
			return false;
		}

		m_exePatcher.reset(new ExecutablePatcher(path));
		if (!m_exePatcher->loaded())
		{
			m_errorCode = Init_UnableToLoadExecutablePatch;
			m_errorData = executablePatchFilename;
			return false;
		}
	}

	m_info.files.clear();

	const QString fileListPath = manifest.value("files").toString();
	if (!fileListPath.isEmpty())
	{
		QString path = fileListPath;
		if (QFileInfo(fileListPath).isRelative())
		{
			path = QFileInfo(manifestPath).absoluteDir().absoluteFilePath(fileListPath);
		}

		QFile file(path);
		if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
		{
			m_errorCode = Init_UnableToLoadFileList;
			m_errorData = fileListPath;
			return false;
		}

		QTextStream stream(&file);
		while (!stream.atEnd())
		{
			const QString filename = stream.readLine().trimmed();
			m_info.files << filename;
		}
	}

	return true;
}

bool PatcherProcessor::openImage(const QString& path)
{
	m_image = imageForPlatform(m_info.platform);

	if (m_image.get() == NULL)
	{
		m_errorCode = Open_UnableToCreateImageForPlatform;
		m_errorData = QString::number(m_info.platform);
		return false;
	}

	if (!m_image->open(path.toStdWString(), Stream::modeReadWrite))
	{
		m_errorCode = Open_UnableToOpenImage;
		m_errorData = path;
		return false;
	}

	if (QByteArray(m_image->discId().c_str()) != m_info.discId)
	{
		m_errorCode = Open_InvalidDiscId;
		m_errorData = QString("%1;%2").arg(QString::fromStdString(m_image->discId())).arg(QString::fromUtf8(m_info.discId.constData()));
		return false;
	}

	return true;
}

static Archive::MergeMap loadMergeMap(const QString& path)
{
	Archive::MergeMap map;

	QtFileStream stream(path, QIODevice::ReadOnly);
	if (stream.opened())
	{
		if ((stream.size() % 8) != 0)
		{
			DLOG << "WARNING: Invalid merge map size!";
		}

		while (!stream.atEnd())
		{
			const quint32 sourceHash = stream.readUInt();
			const quint32 destHash = stream.readUInt();
			map[sourceHash] = destHash;
		}
	}
	else
	{
		DLOG << "NOTICE: Merge map is not present";
	}

	return map;
}

bool PatcherProcessor::rebuildArchives(const QString& outPath, const QStringList& resourcesPaths)
{
	const CompoundProgressNotifier::ProgressGuard guard(m_progressNotifier);
	const QDir outDir(outPath);
	const QDir resDir(resourcesPaths.first());

	TextureDatabase textureDB = TextureDatabase::fromCSV(resDir.absoluteFilePath("textures.csv"));
	if (textureDB.isNull())
	{
		m_errorCode = RebuildArchives_UnableToLoadTextureDatabase;
		m_errorData = "textures.csv";
		return false;
	}

	Archive::MergeMap mergeMap;
	const QString mergeMapFilename = "mergemap.bin";
	if (resDir.exists(mergeMapFilename))
	{
		mergeMap = loadMergeMap(resDir.absoluteFilePath(mergeMapFilename));
	}

	PatcherDirectoriesFileSource arcDirectoriesFileSource(QStringList(resourcesPaths) << outPath);
	PatcherTexturesFileSource arcTexturesFileSource(&arcDirectoriesFileSource, resourcesPaths.first(), textureDB,
		m_info.platform == platformWii ? Stream::orderBigEndian : Stream::orderLittleEndian, m_info.game == gameOrigins);

	if (m_info.game == gameShatteredMemories)
	{
		DLOG << "Rebuilding UI.arc...";

		ArchiveProgressNotifier listener;
		m_progressNotifier.setCurrentNotifier(&listener, 0.04);

		auto_ptr<Stream> pakStream(m_image->openFile(m_info.uiArcContainer.toStdString(), Stream::modeRead));
		if (pakStream.get() == NULL)
		{
			m_errorCode = RebuildArchives_UnableToOpenFileInImage;
			m_errorData = m_info.uiArcContainer;
			return false;
		}

		Archive arc(pakStream.get());
		if (!arc.open())
		{
			m_errorCode = RebuildArchives_UnableToOpenArchive;
			m_errorData = m_info.uiArcContainer;
			return false;
		}

		shared_ptr<Stream> uiArcStream = arc.openFile("ui.arc");
		ASSERT(uiArcStream.unique());
		if (uiArcStream.get() == NULL)
		{
			m_errorCode = RebuildArchives_UnableToOpenFileInArchive;
			m_errorData = m_info.uiArcContainer + QString(";UI.arc");
			return false;
		}

		Archive uiArc(uiArcStream.get());
		if (!uiArc.open())
		{
			m_errorCode = RebuildArchives_UnableToOpenArchive;
			m_errorData = "ui.arc";
			return false;
		}

		uiArc.addProgressListener(&listener);

		const QString filename = outDir.absoluteFilePath(QString::fromStdString(Hash::toString(Hash::calc("ui.arc"))));
		if (!uiArc.rebuild(filename.toStdWString(), arcTexturesFileSource, mergeMap))
		{
			m_errorCode = RebuildArchives_UnableToRebuildArchive;
			m_errorData = "ui.arc";
			return false;
		}
	}

	DLOG << "Rebuilding " << m_info.embededArcName << "...";
	{
		ArchiveProgressNotifier listener;
		m_progressNotifier.setCurrentNotifier(&listener, 0.01);

		auto_ptr<Stream> executableStream(m_image->openFile(m_info.executablePath.toStdString(), Stream::modeRead));
		if (executableStream.get() == NULL)
		{
			m_errorCode = RebuildArchives_UnableToOpenFileInImage;
			m_errorData = m_info.executablePath;
			return false;
		}

		if (executableStream->seek(m_info.embededArcOffset, Stream::seekSet) != m_info.embededArcOffset)
		{
			m_errorCode = RebuildArchives_UnableToSeekInExecutable;
			m_errorData = QString::number(m_info.embededArcOffset, 16);
			return false;
		}

		const EmbededResourceInfo embededArcInfo = EmbededResourceInfo::parse(executableStream.get());
		if (embededArcInfo.isNull())
		{
			m_errorCode = RebuildArchives_UnableToParseEmbededResource;
			m_errorData = m_info.embededArcName;
			return false;
		}

		if (embededArcInfo.contentSize > embededArcInfo.streamSizeLeft - EmbededResourceInfo::s_headerSize)
		{
			m_errorCode = RebuildArchives_InvalidBootArcSize;
			m_errorData = QString::number(embededArcInfo.contentSize, 16);
			return false;
		}

		PartStream executableSegmentStream(executableStream.get(), executableStream->position(), embededArcInfo.contentSize);
		Archive embededArc(&executableSegmentStream);
		if (!embededArc.open())
		{
			m_errorCode = RebuildArchives_UnableToOpenArchive;
			m_errorData = m_info.embededArcName;
			return false;
		}

		embededArc.addProgressListener(&listener);
		const QString filename = outDir.absoluteFilePath(m_info.embededArcName);
		if (!embededArc.rebuild(filename.toStdWString(), arcTexturesFileSource, mergeMap))
		{
			m_errorCode = RebuildArchives_UnableToRebuildArchive;
			m_errorData = m_info.embededArcName;
			return false;
		}
	}

	const QString mainArcName = QFileInfo(m_info.mainArcPath).fileName();

	DLOG << "Rebuilding " << mainArcName << "...";
	{
		ArchiveProgressNotifier listener;
		m_progressNotifier.setCurrentNotifier(&listener);

		auto_ptr<Stream> pakStream(m_image->openFile(m_info.mainArcPath.toStdString(), Stream::modeRead));
		if (pakStream.get() == NULL)
		{
			m_errorCode = RebuildArchives_UnableToOpenFileInImage;
			m_errorData = m_info.mainArcPath;
			return false;
		}

		Archive arc(pakStream.get());
		if (!arc.open())
		{
			m_errorCode = RebuildArchives_UnableToOpenArchive;
			m_errorData = mainArcName;
			return false;
		}

		arc.addProgressListener(&listener);
		const QString filename = outDir.absoluteFilePath(mainArcName);
		if (!arc.rebuild(filename.toStdWString(), arcTexturesFileSource, mergeMap))
		{
			m_errorCode = RebuildArchives_UnableToRebuildArchive;
			m_errorData = mainArcName;
			return false;
		}
	}
	return true;
}

bool PatcherProcessor::checkImage()
{
	CompoundProgressNotifier::ProgressGuard guard(m_progressNotifier);
	m_progressNotifier.setCurrentNotifier(m_image->progressNotifier());

	if (!m_image->checkImage())
	{
		m_errorCode = CheckImage_Failed;
		m_errorData = QString::fromStdString(m_image->lastErrorData());
		return false;
	}

	return true;
}

bool PatcherProcessor::replaceArchives(const QString& arcPath)
{
	const CompoundProgressNotifier::ProgressGuard guard(m_progressNotifier);
	const QDir dir(arcPath);

	auto_ptr<Stream> executableStream(m_image->openFile(m_info.executablePath.toStdString(), Stream::modeRead));
	if (executableStream.get() == NULL)
	{
		m_errorCode = ReplaceArchives_UnableToOpenExecutable;
		m_errorData = m_info.executablePath;
		return false;
	}

	DLOG << "Replacing " << m_info.embededArcName << "...";
	{
		m_progressNotifier.unbindCurrentNotifier();

		executableStream->seek(m_info.embededArcOffset, Stream::seekSet);
		const EmbededResourceInfo info = EmbededResourceInfo::parse(executableStream.get());
		if (info.isNull())
		{
			m_errorCode = ReplaceArchives_UnableToParseEmbededResource;
			m_errorData = m_info.embededArcName;
			return false;
		}

		QtFileStream stream(dir.absoluteFilePath(m_info.embededArcName), QIODevice::ReadOnly);
		if (!stream.opened())
		{
			m_errorCode = ReplaceArchives_UnableToOpenInputPak;
			m_errorData = m_info.embededArcName;
			return false;
		}

		if (stream.size() > info.streamSizeLeft - EmbededResourceInfo::s_headerSize)
		{
			m_errorCode = ReplaceArchives_InputArcFileTooBig;
			m_errorData = m_info.embededArcName;
			return false;
		}

		if (executableStream->writeStream(&stream, stream.size()) != stream.size())
		{
			m_errorCode = ReplaceArchives_UnableToWriteFile;
			m_errorData = m_info.embededArcName;
			return false;
		}

		executableStream->seek(m_info.embededArcOffset + EmbededResourceInfo::s_contentSizeOffset, Stream::seekSet);
		executableStream->writeUInt32(stream.size());
	}

	if (m_info.game == gameShatteredMemories && m_info.uiArcContainer != m_info.mainArcPath)
	{
		DLOG << "Replacing ui.arc...";

		auto_ptr<Stream> arcStream(m_image->openFile(m_info.uiArcContainer.toStdString(), Stream::modeReadWrite));
		if (arcStream.get() == NULL)
		{
			m_errorCode = ReplaceArchives_UnableToOpenArcForReplace;
			m_errorData = m_info.uiArcContainer;
			return false;
		}

		Archive arc(arcStream.get());
		if (!arc.open())
		{
			m_errorCode = ReplaceArchives_UnableToParseArc;
			m_errorData = m_info.uiArcContainer;
			return false;
		}

		const Archive::FileInfo info = arc.fileInfo("ui.arc");
		ASSERT(!info.packed);

		quint32 maxSize = info.size + arc.alignment() - 1;
		maxSize = maxSize - (maxSize % arc.alignment());

		QtFileStream stream(dir.absoluteFilePath(QString::fromStdString(Hash::toString(Hash::calc("ui.arc")))), QIODevice::ReadOnly);
		if (!stream.opened())
		{
			m_errorCode = ReplaceArchives_UnableToOpenInputPak;
			m_errorData = "ui.arc";
			return false;
		}

		if (stream.size() > maxSize)
		{
			DLOG << "Input ui.arc too big: " << stream.size() << " bytes / " << maxSize << " bytes";
			m_errorCode = ReplaceArchives_InputArcFileTooBig;
			m_errorData = QString("ui.arc;%2;%3").arg(stream.size()).arg(maxSize);
			return false;
		}

		if (stream.size() > info.size)
		{
			DLOG << "Writing extended size for ui.arc...";
			arcStream->seek(0x10 + 0x10 * info.index + 8, Stream::seekSet);
			arcStream->writeUInt32(stream.size());
		}

		arcStream->seek(info.offset, Stream::seekSet);
		if (arcStream->writeStream(&stream, stream.size()) != stream.size())
		{
			DLOG << "Unable to write ui.arc!";
			m_errorCode = ReplaceArchives_UnableToWriteFile;
			m_errorData = "ui.arc";
			return false;
		}
	}

	const QString mainArcName = QFileInfo(m_info.mainArcPath).fileName();

	DLOG << "Replacing " << mainArcName << "...";
	{
		m_progressNotifier.setCurrentNotifier(m_image->progressNotifier());

		const DiscImage::FileInfo fileRecord = m_image->findFile(m_info.mainArcPath.toStdString());
		if (fileRecord.isNull())
		{
			m_errorCode = ReplaceArchives_UnableToOpenArcForReplace;
			m_errorData = m_info.mainArcPath;
			return false;
		}

		QtFileStream stream(dir.absoluteFilePath(QFileInfo(m_info.mainArcPath).fileName()), QIODevice::ReadOnly);
		if (!stream.opened())
		{
			m_errorCode = ReplaceArchives_UnableToOpenInputPak;
			m_errorData = m_info.mainArcPath;
			return false;
		}

		if (stream.size() > fileRecord.size)
		{
			DLOG << "Input " << mainArcName << " too big: " << stream.size() << " bytes / " << fileRecord.size << " bytes";
			m_errorCode = ReplaceArchives_InputArcFileTooBig;
			m_errorData = QString("%1;%2;%3").arg(mainArcName).arg(stream.size()).arg(fileRecord.size);
			return false;
		}

		const bool written = m_image->writeData(fileRecord.offset, &stream, stream.size());
		if (!written)
		{
			DLOG << "Unable to write " << mainArcName << "!";
			m_errorCode = ReplaceArchives_UnableToWriteFile;
			m_errorData = mainArcName;
			return false;
		}

		if (m_info.game == gameShatteredMemories)
		{
			executableStream->seek(m_info.headersOffset, Stream::seekSet);
			const EmbededResourceInfo info = EmbededResourceInfo::parse(executableStream.get());
			if (info.isNull())
			{
				m_errorCode = ReplaceArchives_UnableToParseEmbededResource;
				m_errorData = mainArcName;
				return false;
			}

			m_progressNotifier.unbindCurrentNotifier();
			stream.seek(0, Stream::seekSet);
			if (executableStream->writeStream(&stream, info.contentSize) != info.contentSize)
			{
				m_errorCode = ReplaceArchives_UnableToWriteFile;
				m_errorData = QString("header:%1").arg(mainArcName);
				return false;
			}
		}
	}

	DLOG << "Patching executable...";
	{
		if (m_exePatcher.get() != NULL && m_exePatcher->loaded())
		{
			executableStream->setByteOrder(m_info.platform == platformWii ? Stream::orderBigEndian : Stream::orderLittleEndian);
			if (!m_exePatcher->apply(executableStream.get()))
			{
				m_errorCode = PatchExecutable_UnableToPatchMainDol;
				m_errorData = QString();
				return false;
			}
		}
	}

	return true;
}


bool PatcherProcessor::replaceFiles(const QStringList& resourcesPaths)
{
	if (m_info.files.isEmpty())
	{
		return true;
	}

	class DummyFileAccessor : public FileSource::FileAccessor
	{
		virtual std::tr1::shared_ptr<Stream> open() override
		{
			return std::tr1::shared_ptr<Stream>();
		}
	};

	DLOG << "Replacing files...";

	PatcherDirectoriesFileSource fileSource(resourcesPaths);

	foreach (const QString& filename, m_info.files)
	{
		const QString baseName = QFileInfo(filename).fileName();
		std::tr1::shared_ptr<Stream> stream = fileSource.fileByName(baseName.toStdString(), DummyFileAccessor());
		if (stream.get() == NULL || stream->size() <= 0)
		{
			m_errorCode = ReplaceArchives_UnableToOpenInputFileToReplace;
			m_errorData = baseName;
			return false;
		}

		std::auto_ptr<Stream> imageFileStream(m_image->openFile(filename.toStdString(), Stream::modeWrite));
		if (imageFileStream.get() == NULL)
		{
			m_errorCode = ReplaceArchives_UnableToOpenFileToReplace;
			m_errorData = filename;
			return false;
		}

		if (imageFileStream->size() < stream->size())
		{
			m_errorCode = ReplaceArchives_InputFileTooBig;
			m_errorData = QString("%1;%2;%3").arg(filename).arg(stream->size()).arg(imageFileStream->size());
			return false;
		}

		if (imageFileStream->writeStream(stream.get(), stream->size()) != stream->size())
		{
			m_errorCode = ReplaceArchives_UnableToWriteFile;
			m_errorData = filename;
			return false;
		}
	}

	return true;
}

bool PatcherProcessor::checkArchives(const QString& arcPath)
{
	CompoundProgressNotifier::ProgressGuard guard(m_progressNotifier);
	const QDir dir(arcPath);

	DLOG << "Checking " << m_info.embededArcName << "...";
	{
		auto_ptr<Stream> executableStream(m_image->openFile(m_info.executablePath.toStdString(), Stream::modeRead));
		if (executableStream.get() == NULL)
		{
			m_errorCode = CheckArchives_UnableToOpenExecutable;
			m_errorData = m_info.executablePath;
			return false;
		}

		VERIFY(executableStream->seek(m_info.embededArcOffset, Stream::seekSet) == m_info.embededArcOffset);

		const EmbededResourceInfo embededArcInfo = EmbededResourceInfo::parse(executableStream.get());
		if (embededArcInfo.isNull())
		{
			m_errorCode = CheckArchives_UnableToParseEmbededResource;
			m_errorData = m_info.embededArcName;
			return false;
		}

		if (embededArcInfo.contentSize > embededArcInfo.streamSizeLeft - EmbededResourceInfo::s_headerSize)
		{
			m_errorCode = CheckArchives_InvalidBootArcSize;
			m_errorData = QString::number(embededArcInfo.contentSize, 16);
			return false;
		}

		PartStream embededArcStream(executableStream.get(), executableStream->position(), embededArcInfo.contentSize);

		QtFileStream resultArcSream(dir.absoluteFilePath(m_info.embededArcName), QIODevice::ReadOnly);
		if (!resultArcSream.opened())
		{
			m_errorCode = CheckArchives_UnableToOpenResultArchive;
			m_errorData = m_info.embededArcName;
			return false;
		}

		if (!compareStreams(&embededArcStream, &resultArcSream, false, 0.01))
		{
			m_errorCode = CheckArchives_ArcsAreNotEqual;
			m_errorData = m_info.embededArcName;
			return false;
		}
	}

	if (m_info.game == gameShatteredMemories)
	{
		DLOG << "Checking ui.arc...";

		auto_ptr<Stream> pakStream(m_image->openFile(m_info.uiArcContainer.toStdString(), Stream::modeReadWrite));
		if (pakStream.get() == NULL)
		{
			m_errorCode = CheckArchives_UnableToOpenArchive;
			m_errorData = m_info.uiArcContainer;
			return false;
		}

		Archive arc(pakStream.get());
		if (!arc.open())
		{
			m_errorCode = CheckArchives_UnableToParseArchive;
			m_errorData = m_info.uiArcContainer;
			return false;
		}

		shared_ptr<Stream> uiArcStream = arc.openFile("ui.arc");
		if (uiArcStream.get() == NULL)
		{
			m_errorCode = CheckArchives_UnableToOpenArchive;
			m_errorData = "ui.arc";
			return false;
		}

		QtFileStream resultArcSream(dir.absoluteFilePath(QString::fromStdString(Hash::toString(Hash::calc("ui.arc")))), QIODevice::ReadOnly);
		if (!resultArcSream.opened())
		{
			m_errorCode = CheckArchives_UnableToOpenResultArchive;
			m_errorData = "ui.arc";
			return false;
		}

		if (!compareStreams(uiArcStream.get(), &resultArcSream, true, 0.04))
		{
			m_errorCode = CheckArchives_ArcsAreNotEqual;
			m_errorData = "ui.arc";
			return false;
		}
	}

	const QString mainArcName = QFileInfo(m_info.mainArcPath).fileName();

	DLOG << "Checking " << mainArcName << "...";
	{
		QtFileStream resultArcSream(dir.absoluteFilePath(mainArcName), QIODevice::ReadOnly);
		if (!resultArcSream.opened())
		{
			m_errorCode = CheckArchives_UnableToOpenResultArchive;
			m_errorData = mainArcName;
			return false;
		}

		if (m_info.game == gameShatteredMemories)
		{
			auto_ptr<Stream> executableStream(m_image->openFile(m_info.executablePath.toStdString(), Stream::modeRead));
			if (executableStream.get() == NULL)
			{
				m_errorCode = CheckArchives_UnableToOpenExecutable;
				m_errorData = m_info.executablePath;
				return false;
			}

			VERIFY(executableStream->seek(m_info.headersOffset, Stream::seekSet) == m_info.headersOffset);

			const EmbededResourceInfo info = EmbededResourceInfo::parse(executableStream.get());
			if (info.isNull())
			{
				m_errorCode = CheckArchives_UnableToParseEmbededResource;
				m_errorData = mainArcName;
				return false;
			}

			PartStream header(executableStream.get(), executableStream->position(), info.contentSize);
			if (!compareStreams(&header, &resultArcSream, true, 0.01))
			{
				m_errorCode = CheckData_FilesAreDifferent;
				m_errorData = QString("header:%1").arg(mainArcName);
				return false;
			}
		}

		auto_ptr<Stream> arcStream(m_image->openFile(m_info.mainArcPath.toStdString(), Stream::modeRead));
		if (arcStream.get() == NULL)
		{
			m_errorCode = CheckArchives_UnableToOpenArchive;
			m_errorData = mainArcName;
			return false;
		}

		if (!compareStreams(arcStream.get(), &resultArcSream, true))
		{
			m_errorCode = CheckData_FilesAreDifferent;
			m_errorData = mainArcName;
			return false;
		}
	}

	return true;
}

static int s2c(int size)
{
	const int cluster = 0x7C00;
	return (size + cluster - 1) / cluster;
}

bool PatcherProcessor::compareStreams(Stream* stream1, Stream* stream2, bool ignoreSize, double progressCoeff)
{
	largesize_t size = min(stream1->size(), stream2->size());
	CheckingProgressNotifier notifier(s2c(size));
	m_progressNotifier.setCurrentNotifier(&notifier, progressCoeff);

	if (!ignoreSize && stream1->size() != stream2->size())
	{
		return false;
	}

	stream1->seek(0, Stream::seekSet);
	stream2->seek(0, Stream::seekSet);

	const int chunk = 0x7C00;
	char data1[chunk];
	char data2[chunk];

	int processed = 0;
	while (size > 0)
	{
		notifier.progress(s2c(processed));

		if (notifier.stopRequested())
		{
			return false;
		}

		const largesize_t toRead = std::min<largesize_t>(chunk, size);
		size -= chunk;

		const largesize_t readed1 = stream1->read(&data1[0], toRead);
		const largesize_t readed2 = stream2->read(&data2[0], toRead);
		if (readed1 != readed2 || readed1 != toRead)
		{
			DLOG << __FUNCTION__ << ": I/O error!";
			return false;
		}
		processed += readed1;

		if (!std::equal(&data1[0], &data1[readed1], &data2[0]))
		{
			return false;
		}
	}
	return true;
}

int PatcherProcessor::errorCode() const
{
	return m_errorCode;
}

QString PatcherProcessor::errorData() const
{
	return m_errorData;
}

QObject* PatcherProcessor::progressNotifier()
{
	return &m_progressNotifier;
}

PatcherProcessor::ErrorCategory PatcherProcessor::errorCategory(ErrorCode error)
{
	if (error == NoError)
	{
		return category_Undefined;
	}

	return static_cast<ErrorCategory>(error >> 4);
}

}
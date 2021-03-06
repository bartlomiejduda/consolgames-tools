#pragma once
#include "Category.h"
#include <Strings.h>
#include <QSet>
#include <memory>

class MessageSetModel;
class MessageSetFilterModel;
class QItemSelectionModel;
class QSortFilterProxyModel;
class QAbstractItemModel;
class CategoriesModel;
class MainFrame;

class MainController : public QObject
{
	Q_OBJECT

public:
	MainController(MainFrame* parent);
	~MainController();

	QAbstractItemModel* messagesModel() const;
	QAbstractItemModel* messagesFilterModel() const;
	QItemSelectionModel* messagesSelectionModel() const;
	QAbstractItemModel* categoriesModel() const;
	QItemSelectionModel* categoriesSelectionModel() const;

	const ShatteredMemories::MessageSet& mainLanguageData() const;
	const ShatteredMemories::MessageSet& mainSourceLanguageData() const;
	const ShatteredMemories::MessageSet& languageData(const QByteArray& languageId) const;
	const QList<QByteArray> languages() const;
	const QByteArray& mainLanguageId() const;
	const QMap<quint32,QString>& comments() const;
	const QMap<quint32, QStringList>& tags() const;

	quint32 currentHash() const;
	bool somethingIsChanged() const;
	bool saveTranslationData();
	void copyHashesToClipboard();

private:
	void initCategories();
	void initCategoriesModels();
	void initMessagesModels();
	void loadComments();
	void loadAuthors();
	void loadTags();
	void loadLanguages();
	void loadMainLanguage(const QByteArray& languageId, const QString& path);
	void loadSourceLanguage(const QByteArray& languageId, const QString& path);
	void setMainSourceLanguage(const QByteArray& languageId);

	bool saveMainLanguage();
	bool saveComments();
	bool saveCategories();
	bool saveAuthors();
	bool saveTags();

	Q_SIGNAL void loadingLanguage(const QByteArray& languageId);
	Q_SIGNAL void messageSelected(quint32 hash);

	Q_SLOT void onCategoryChanged(const QModelIndex& index);
	Q_SLOT void onMessageChanged(const QModelIndex& index);
	Q_SLOT void onTextChanged(const QString& text, const QByteArray& languageId, quint32 hash);
	Q_SLOT void onFilterChanged(const QString& pattern);
	Q_SLOT void onCommentChanged(const QString& text, quint32 hash);
	Q_SLOT void onTagsChanged(const QStringList& text, quint32 hash);
	Q_SLOT void updateTranslationStatistics(quint32 hash, const QString& changedText, const QStringList& changedTags);
	void decreaseTranslatedCount(quint32 hash);
	void increaseTranslatedCount(quint32 hash);
	void increaseTranslatedCount(quint32 hash, const Category& category, int value);
	int translatedCount(const QList<quint32>& hashes) const;
	void calculateTranslatedCount(const Category& category);

private:
	MainFrame* m_parent;

	MessageSetModel* m_messagesModel;
	MessageSetFilterModel* m_messagesFilterModel;
	QItemSelectionModel* m_messagesSelectionModel;
	CategoriesModel* m_categoriesModel;
	QItemSelectionModel* m_categoriesSelectionModel;

	bool m_languageChanged;
	bool m_authorsChanged;
	bool m_commentsChanged;
	bool m_categoriesChanged;
	bool m_tagsChanged;
	QByteArray m_mainLanguageId;
	QByteArray m_mainSourceLanguageId;

	QMap<QByteArray, ShatteredMemories::MessageSet> m_scripts;
	QMap<QString, QList<quint32>> m_filesInfo;
	Category m_rootCategory;
	QMap<quint32, QString> m_comments;
	QMap<quint32, QString> m_authors;
	QMap<quint32, QStringList> m_tags;
	QMap<const Category*, QPair<int, int>> m_translatedCount;
};
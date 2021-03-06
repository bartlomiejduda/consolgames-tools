#pragma once
#include <QSortFilterProxyModel>
#include <QSet>
#include <QStringList>

class MessageSetFilterModel : public QSortFilterProxyModel
{
public:
	MessageSetFilterModel(QObject* parent = NULL);
	Q_SLOT void setPattern(const QString& pattern);

protected:
	bool hasVisibleRows(int row) const;
	virtual bool filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const override;
	bool stringSatisfyFilter(const QString& text) const;
	bool containsAnyTag(quint32 hash) const;

protected:
	QString m_pattern;
	bool m_patternAtBegin;
	bool m_patternAtEnd;
	Qt::CaseSensitivity m_caseSensitivity;
	QSet<quint32> m_hashes;
	QStringList m_tags;
};
#pragma once
#include <QSortFilterProxyModel>

class MessageSetFilterModel : public QSortFilterProxyModel
{
public:
	MessageSetFilterModel();
	void setPattern(const QString& pattern);

protected:
	bool hasVisibleRows(int row) const;
	virtual bool filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const override;
	bool stringSatisfyFilter(const QString& text) const;

protected:
	QString m_pattern;
	bool m_patternAtBegin;
	bool m_patternAtEnd;
	quint64 m_filterHash;
	int m_filterIndex;
	Qt::CaseSensitivity m_caseSensitivity;
};
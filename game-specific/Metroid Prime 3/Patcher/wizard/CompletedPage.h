#pragma once
#include "Page.h"
#include "ui_CompletedPage.h"

class CompletedPage : public Page<Ui_CompletedPage>
{
	Q_OBJECT

public:
	CompletedPage();
	virtual void initializePage();

	Q_SLOT void operURLs();
};
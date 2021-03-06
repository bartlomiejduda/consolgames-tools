#include "CompletedPage.h"
#include <core.h>
#include <QDesktopServices>
#include <QUrl>

CompletedPage::CompletedPage() : Page<Ui_CompletedPage>()
{
	setFinalPage(true);
}

void CompletedPage::initializePage()
{
	wizard()->setButtonLayout(QList<QWizard::WizardButton>() << QWizard::Stretch << QWizard::FinishButton);
	VERIFY(connect(wizard()->button(QWizard::FinishButton), SIGNAL(clicked()), SLOT(operURLs())));
}

void CompletedPage::operURLs()
{
	if (m_ui.openProjectPage->isChecked())
	{
		QDesktopServices::openUrl(QUrl("http://consolgames.ru/translations/Metroid_Prime_3"));
	}
	if (m_ui.openForumThread->isChecked())
	{
		QDesktopServices::openUrl(QUrl("http://consolgames.ru/forum/index.php?showtopic=204"));
	}
	if (m_ui.openVKGroup->isChecked())
	{
		QDesktopServices::openUrl(QUrl("http://vk.com/club18909038"));
	}
}
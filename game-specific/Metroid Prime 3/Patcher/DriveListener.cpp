#include "DriveListener.h"
#include <dbt.h>

DriveListener::DriveListener(QWidget* parent)
	: QWidget(parent)
	, m_uid(QUuid::createUuid())
	, m_handle(NULL)
{
	DLOG << "DriveListener created";
 	registerDeviceNotification();
}

void DriveListener::registerDeviceNotification()
{
	DEV_BROADCAST_DEVICEINTERFACE notificationFilter;
	ZeroMemory(&notificationFilter, sizeof(notificationFilter));
	notificationFilter.dbcc_size = sizeof(DEV_BROADCAST_DEVICEINTERFACE);
	notificationFilter.dbcc_devicetype = DBT_DEVTYP_DEVICEINTERFACE;
	notificationFilter.dbcc_classguid  = m_uid;
	m_handle = RegisterDeviceNotification(winId(), &notificationFilter, DEVICE_NOTIFY_WINDOW_HANDLE);
	ASSERT(m_handle != NULL);
}

bool DriveListener::winEvent(MSG* message, long* result)
{
	Q_UNUSED(result);

	if (message->message == WM_DEVICECHANGE)
	{
		if (message->wParam == DBT_DEVICEARRIVAL || message->wParam == DBT_DEVICEREMOVECOMPLETE)
		{
			const DEV_BROADCAST_HDR* pMsgPtr = reinterpret_cast<DEV_BROADCAST_HDR*>(message->lParam);

			if (pMsgPtr != NULL)
			{
				if (pMsgPtr->dbch_devicetype == DBT_DEVTYP_VOLUME)
				{
					const DEV_BROADCAST_VOLUME* volume = reinterpret_cast<const DEV_BROADCAST_VOLUME*>(pMsgPtr);
					
					QList<QChar> letterList;
					for (int i = 0; i < 24; i++)
					{
						if (volume->dbcv_unitmask & (1 << i))
						{
							const QChar letter = QChar::fromAscii('A' + i);
							letterList << letter;
							DLOG << "Drive state changed: " << letter;
						}
					}

					if (message->wParam == DBT_DEVICEARRIVAL)
					{
						emit drivesInserted(letterList);
					}
					else
					{
						emit drivesRemoved(letterList);
					}
				}
			}
		}
		return true;
	}
	return false;
}

void DriveListener::unregisterDeviceNotification()
{
	if (m_handle != NULL)
	{
		VERIFY(UnregisterDeviceNotification(m_handle));
	}
}

DriveListener::~DriveListener()
{
	DLOG << "DriveListener destroyed";
	unregisterDeviceNotification();
}

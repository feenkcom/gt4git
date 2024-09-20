Class {
	#name : #GtFetchingNotificationJob,
	#superclass : #GtNotificationJob,
	#category : #'GToolkit4Git-Refactorings'
}

{ #category : #accessing }
GtFetchingNotificationJob >> registerNotifications [
	GtWorld allInstancesDo: [ :world | world showNotification: self ]
]

{ #category : #accessing }
GtFetchingNotificationJob >> summaryClass [
	^ GtFetchingNotificationSummary
]

Class {
	#name : #GtFetchingNotificationSummary,
	#superclass : #GtNotificationSummary,
	#instVars : [
		'executedLabel'
	],
	#category : #'GToolkit4Git-Refactorings'
}

{ #category : #accessing }
GtFetchingNotificationSummary >> initialize [
	super initialize.
	self
		constraintsDo: [ :c | 
			c vertical exact: 21.
			c horizontal fitContent ].
	self layout: BlLinearLayout horizontal.
	self border: (BlBorder paint: Color orange width: 2).
	self geometry: (BlRoundedRectangleGeometry cornerRadius: 4).
	self padding: (BlInsets left: 5 right: 5).
	self background: Color white.

	self
		addChild: (executedLabel := BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					beSmallSize;
					hFitContent;
					vExact: 15;
					margin: (BlInsets all: 3);
					layout: BlLinearLayout horizontal alignCenter;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
					text: 'Fetching 0/0')
]

{ #category : #accessing }
GtFetchingNotificationSummary >> subscribeToNotifications [
	notifications
		do: [ :each | 
			each job announcer
				when: JobChange
				send: #requestUpdate
				to: self ]
]

{ #category : #accessing }
GtFetchingNotificationSummary >> unsubscribeFromNotifications [
	notifications do: [ :each | each job announcer unsubscribe: self ]
]

{ #category : #accessing }
GtFetchingNotificationSummary >> updateSummaryContent [
	| fetched total |
	fetched := total := 0.
	self notifications
		do: [ :each | 
			fetched := fetched + each job currentValue.
			total := total + each job max ].
	executedLabel text: 'Fetching ' , fetched printString , '/' , total printString
]

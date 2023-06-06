Class {
	#name : #GtLepiterLinksSnapshot,
	#superclass : #GtLepiterSnapshot,
	#instVars : [
		'linksUuid',
		'linksContents',
		'linksFileName'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'instance creation' }
GtLepiterLinksSnapshot class >> fromExplicitLinks: anExplicitLinksGroup inDatabase: aDatabase [
	^ self new
		initializeFomExplicitLinksGroup: anExplicitLinksGroup
		inDatabase: aDatabase
]

{ #category : #initialization }
GtLepiterLinksSnapshot >> initializeFomExplicitLinksGroup: anExplicitLinksGroup inDatabase: aDatabase [

	self linksUuid: anExplicitLinksGroup uid.
	aDatabase monitor explicitLinksFileReference ifNotNil: [ 
		self linksFileName:
			aDatabase monitor explicitLinksFileReference basename.
		self linksContents:
			aDatabase monitor explicitLinksFileReference contents ]
]

{ #category : #accessing }
GtLepiterLinksSnapshot >> linksContents [

	^ linksContents
]

{ #category : #accessing }
GtLepiterLinksSnapshot >> linksContents: anObject [

	linksContents := anObject
]

{ #category : #accessing }
GtLepiterLinksSnapshot >> linksFileName [

	^ linksFileName
]

{ #category : #accessing }
GtLepiterLinksSnapshot >> linksFileName: anObject [

	linksFileName := anObject
]

{ #category : #accessing }
GtLepiterLinksSnapshot >> linksUuid [

	^ linksUuid
]

{ #category : #accessing }
GtLepiterLinksSnapshot >> linksUuid: anObject [

	linksUuid := anObject
]

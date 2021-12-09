Class {
	#name : #GtLepiterPageSnapshot,
	#superclass : #GtLepiterSnapshot,
	#instVars : [
		'pageUuid',
		'content',
		'pageTitle'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'instance-creation' }
GtLepiterPageSnapshot class >> fromPage: aPage [ 
	^ self new
		initializeFromPage: aPage
]

{ #category : #accessing }
GtLepiterPageSnapshot >> content [

	^ content
]

{ #category : #accessing }
GtLepiterPageSnapshot >> content: anObject [

	content := anObject
]

{ #category : #initialization }
GtLepiterPageSnapshot >> initializeFromPage: aPage [ 
	self pageUuid: aPage uid.
	self pageTitle: aPage title
]

{ #category : #accessing }
GtLepiterPageSnapshot >> pageTitle [
	^ pageTitle
]

{ #category : #accessing }
GtLepiterPageSnapshot >> pageTitle: anObject [

	pageTitle := anObject
]

{ #category : #accessing }
GtLepiterPageSnapshot >> pageUuid [

	^ pageUuid
]

{ #category : #accessing }
GtLepiterPageSnapshot >> pageUuid: anObject [

	pageUuid := anObject
]

{ #category : #printing }
GtLepiterPageSnapshot >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< '('.
	self pageTitle ifNotNil: [ :aTitle | 
		aStream
			<< aTitle;
			<< ', ' ].
	aStream
		<< self pageUuid asString36;
		<< ')'
]

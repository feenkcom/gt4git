Class {
	#name : #GtLepiterPageSnapshot,
	#superclass : #GtLepiterSnapshot,
	#instVars : [
		'pageUuid',
		'pageTitle',
		'pageContents'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'instance-creation' }
GtLepiterPageSnapshot class >> fromPage: aPage [ 
	^ self new
		initializeFromPage: aPage
]

{ #category : #initialization }
GtLepiterPageSnapshot >> initializeFromPage: aPage [ 
	self pageUuid: aPage uid.
	self pageTitle: aPage title.
	self pageContents: (aPage database monitor 
		pageFileReference: aPage) contents.
]

{ #category : #accessing }
GtLepiterPageSnapshot >> pageContents [
	^ pageContents
]

{ #category : #initialization }
GtLepiterPageSnapshot >> pageContents: aPageContent [
	pageContents := aPageContent
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

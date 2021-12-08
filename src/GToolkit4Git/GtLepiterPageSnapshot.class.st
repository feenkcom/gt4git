Class {
	#name : #GtLepiterPageSnapshot,
	#superclass : #GtLepiterSnapshot,
	#instVars : [
		'pageName',
		'pageUuid',
		'content'
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
	self pageUuid: aPage uid
]

{ #category : #accessing }
GtLepiterPageSnapshot >> pageName [

	^ pageName
]

{ #category : #accessing }
GtLepiterPageSnapshot >> pageName: anObject [

	pageName := anObject
]

{ #category : #accessing }
GtLepiterPageSnapshot >> pageUuid [

	^ pageUuid
]

{ #category : #accessing }
GtLepiterPageSnapshot >> pageUuid: anObject [

	pageUuid := anObject
]

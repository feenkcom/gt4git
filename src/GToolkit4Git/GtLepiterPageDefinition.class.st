Class {
	#name : #GtLepiterPageDefinition,
	#superclass : #GtLepiterDefinition,
	#instVars : [
		'pageUuid',
		'pageTitle',
		'pageContents',
		'fileName',
		'database'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #comparing }
GtLepiterPageDefinition >> = anotherDefinition [

	^ super = anotherDefinition
		and: [ self pageUuid = anotherDefinition pageUuid	 
			and: [ self pageContents = anotherDefinition pageContents ] ]
]

{ #category : #visiting }
GtLepiterPageDefinition >> accept: aVisitor [
	
	^ aVisitor visitLepiterPage: self
]

{ #category : #accessing }
GtLepiterPageDefinition >> asMCDefinition [

	| aDatabase aPage |
	aDatabase := LeDatabase allInstances detect: [ :d | 
		             d uuid = database databaseId ].
	aPage := aDatabase pageByUuid: self pageUuid ifAbsent: [ 
		         | page |
		         page := self asPage.
		         aDatabase addPage: page.
		         page ].
	(aDatabase monitor pageFileReference: aPage) writeStreamDo: [ :s | 
		s truncate.
		s nextPutAll: self pageContents ].
	aPage reloadFromPage: (aDatabase monitor storage loadFromFile:
			 (aDatabase monitor pageFileReference: aPage)).
	^ MCMockDefinition token: self key
]

{ #category : #accessing }
GtLepiterPageDefinition >> asPage [

	^ LeJsonV4 uniqueInstance deserialize:
			          self pageContents readStream
]

{ #category : #accessing }
GtLepiterPageDefinition >> canBeBrowsed [
	^ true
]

{ #category : #accessing }
GtLepiterPageDefinition >> contents [
	^ self pageContents
]

{ #category : #accessing }
GtLepiterPageDefinition >> database: aDatabase [
	database := aDatabase
]

{ #category : #accessing }
GtLepiterPageDefinition >> fileName [

	^ fileName
]

{ #category : #accessing }
GtLepiterPageDefinition >> fileName: anObject [

	fileName := anObject
]

{ #category : #'gt-extensions' }
GtLepiterPageDefinition >> gtViewJsonContentsFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Contents';
		priority: 80;
		aptitude: BrGlamorousCodeEditorAptitude;
		styler: JSONParser gtStyler;
		text: [ self pageContents]
]

{ #category : #comparing }
GtLepiterPageDefinition >> hash [
	^ (super hash 
		bitXor: self pageUuid hash)
		bitXor: self pageContents hash
]

{ #category : #accessing }
GtLepiterPageDefinition >> key [
	^ self fileName
]

{ #category : #accessing }
GtLepiterPageDefinition >> pageContents [
	^ pageContents
]

{ #category : #accessing }
GtLepiterPageDefinition >> pageContents: aString [
	pageContents := aString
]

{ #category : #accessing }
GtLepiterPageDefinition >> pageTitle [

	^ pageTitle
]

{ #category : #accessing }
GtLepiterPageDefinition >> pageTitle: anObject [

	pageTitle := anObject
]

{ #category : #accessing }
GtLepiterPageDefinition >> pageUuid [
	^ pageUuid
]

{ #category : #accessing }
GtLepiterPageDefinition >> pageUuid: anUuid [
	pageUuid := anUuid
]

{ #category : #printing }
GtLepiterPageDefinition >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< '('.
	self name ifNotNil: [ :aTitle | 
		aStream
			<< aTitle;
			<< ', ' ].
	aStream
		<< self pageUuid asString36;
		<< ')'
]

{ #category : #accessing }
GtLepiterPageDefinition >> removeFrom: aVisitor [
	| aDatabase aPage |
	aDatabase := LeDatabase allInstances detect: [ :d | 
		             d uuid = database databaseId ].
	aPage := aDatabase pageByUuid: self pageUuid.
	aDatabase removePage: aPage
]

{ #category : #accessing }
GtLepiterPageDefinition >> toolIn: aRepository [

	| aDatabase aPage |
	aDatabase := LeDatabase allInstances detect: [ :d | 
		             d uuid = database databaseId ].
	aPage := aDatabase pageByUuid: self pageUuid ifAbsent: [ self asPage ].
	^ LePagePhlowTool page: aPage
]

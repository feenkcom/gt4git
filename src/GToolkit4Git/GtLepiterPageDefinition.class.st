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

{ #category : #'*GToolkit4Git' }
GtLepiterPageDefinition class >> gtDiffChangeFrom: aContent to: anotherContent [
	^ GtDiffBuilder
		computeDifferencesFrom: aContent
		to: anotherContent
		using: GtSmaCCDiffSplitter forJSON
]

{ #category : #'*GToolkit4Git' }
GtLepiterPageDefinition class >> gtStyler [
	^ JSONParser gtStyler
]

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
GtLepiterPageDefinition >> toolIn: aGtRepository [

	| targetDatabase targetPage |
	targetDatabase := aGtRepository lepiterWorkingCopy databases 
		detect: [ :aDatabase | aDatabase uuid = database databaseId ].
	
	targetPage := targetDatabase pageByUuid: self pageUuid ifAbsent: [ self asPage ].
	^ targetPage asLepiterPagePhlowToolWithoutFocus
]

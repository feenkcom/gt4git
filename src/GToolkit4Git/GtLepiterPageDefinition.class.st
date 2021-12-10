Class {
	#name : #GtLepiterPageDefinition,
	#superclass : #GtLepiterDefinition,
	#instVars : [
		'pageUuid',
		'pageContents'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #comparing }
GtLepiterPageDefinition >> = anotherDefinition [

	^ super = anotherDefinition
		and: [ self pageContents = anotherDefinition pageContents ]
]

{ #category : #visiting }
GtLepiterPageDefinition >> accept: aVisitor [
	
	^ aVisitor visitLepiterPage: self
]

{ #category : #accessing }
GtLepiterPageDefinition >> contents [
	^ self pageContents
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
	^ super hash 
		bitXor: self pageContents hash
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

Class {
	#name : #GtLepiterInsideCommitDatabase,
	#superclass : #Object,
	#instVars : [
		'localRoot',
		'commit',
		'database'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterInsideCommitDatabase >> commit [

	^ commit
]

{ #category : #accessing }
GtLepiterInsideCommitDatabase >> commit: anObject [

	commit := anObject
]

{ #category : #accessing }
GtLepiterInsideCommitDatabase >> database [
	^ database ifNil: [ 
		database := LeLocalStoreLoad current 
			onlyLoadFrom: self localRoot ]
]

{ #category : #'gt-extensions' }
GtLepiterInsideCommitDatabase >> gtViewLiveDatabaseFor: aView [
	<gtView>
	^ aView forward
		title: 'Database';
		object: [ self database ];
		view: #gtLiveFor:
]

{ #category : #accessing }
GtLepiterInsideCommitDatabase >> localRoot [

	^ localRoot
]

{ #category : #accessing }
GtLepiterInsideCommitDatabase >> localRoot: anObject [

	localRoot := anObject
]

{ #category : #printing }
GtLepiterInsideCommitDatabase >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< '(';
		<< self localRoot asString;
		<< ')'
]

Class {
	#name : #GtGitBranchCreationPane,
	#superclass : #Object,
	#instVars : [
		'branchName',
		'acceptAction',
		'cancelAction'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #accessing }
GtGitBranchCreationPane >> acceptAction [
	^ acceptAction ifNil: [ 
		[ :aModel :aButton :aMemento :aDescription |
			aButton phlow spawnObject: self ] ]
]

{ #category : #accessing }
GtGitBranchCreationPane >> acceptAction: anAction [
	acceptAction := anAction
]

{ #category : #converting }
GtGitBranchCreationPane >> asElement [
	^ self asGtMagritteViewModel asElement padding: (BlInsets all: 10)
]

{ #category : #accessing }
GtGitBranchCreationPane >> branchName [
	^ branchName
]

{ #category : #accessing }
GtGitBranchCreationPane >> branchName: aString [
	branchName := aString
]

{ #category : #magritte }
GtGitBranchCreationPane >> branchNameDescription [
	<magritteDescription>
	^ MAStringDescription new
		priority: 3;
		label: 'Branch name';
		accessor: #branchName;
		default: ''
]

{ #category : #accessing }
GtGitBranchCreationPane >> cancelAction [
	^ cancelAction ifNil: [ 
		[ :aModel :aButton :aMemento :aDescription | ] ]
]

{ #category : #accessing }
GtGitBranchCreationPane >> cancelAction: anAction [
	cancelAction := anAction
]

{ #category : #magritte }
GtGitBranchCreationPane >> magritteAcceptAction [
	<magritteActionDescription>
	^ super magritteAcceptAction
		label: 'Create new branch';
		onSuccessCallback: (GtMagritteCallback new action: self acceptAction)
]

{ #category : #magritte }
GtGitBranchCreationPane >> magritteCancelAction [
	<magritteActionDescription>
	^ super magritteCancelAction
		onSuccessCallback: (GtMagritteCallback new action: self cancelAction)
]

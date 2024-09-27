Class {
	#name : #GtGitBranchCreationPane,
	#superclass : #GtGitMagrittePane,
	#instVars : [
		'branchName'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #magritte }
GtGitBranchCreationPane >> acceptLabel [
	^ 'Create new branch'
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

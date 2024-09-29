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
		default: '';
		required;
		addCondition: [ :aValue | (aValue includesSubstring: '..') not ]
			labelled: 'May not contain ".."';
		addCondition: [ :aValue | (aValue includesAny: '~^:?*[\') not ]
			labelled: 'May not contain any of "~^:?*[\"';
		addCondition: [ :aValue | (aValue endsWith: '.') not ]
			labelled: 'May not end with a dot';
		addCondition: [ :aValue | ((aValue beginsWith: '/') or: [ aValue endsWith: '/' ]) not ]
			labelled: 'May not start or end with a slash';
		addCondition: [ :aValue | (aValue includesSubstring: '@{') not ]
			labelled: 'May not contain the sequence "@{"';
		addCondition: [ :aValue | (aValue = '@') not ]
			labelled: 'May not just be an "@" charater';
		addCondition: [ :aValue | (aValue includesSubstring: '//') not ]
			labelled: 'May not contain multiple consecutive slashes';
		comment: 'A branch name.';
		addCondition: [ :aValue | aValue trimBoth isNotEmpty ]
			labelled: 'Must be non empty'
]

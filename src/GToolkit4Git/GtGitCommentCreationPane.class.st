Class {
	#name : #GtGitCommentCreationPane,
	#superclass : #GtGitMagrittePane,
	#instVars : [
		'comment'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #magritte }
GtGitCommentCreationPane >> acceptLabel [
	^ 'Commit staged changes'
]

{ #category : #accessing }
GtGitCommentCreationPane >> comment [
	^ comment
]

{ #category : #accessing }
GtGitCommentCreationPane >> comment: aString [
	comment := aString
]

{ #category : #magritte }
GtGitCommentCreationPane >> commentDescription [
	<magritteDescription>
	^ MAStringDescription new
		priority: 3;
		label: 'Commit comment';
		accessor: #comment;
		default: '';
		beRequired;
		addCondition: [ :aValue | aValue trimBoth isNotEmpty ]
			labelled: 'Comment must be non empty'
]

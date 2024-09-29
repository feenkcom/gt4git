Class {
	#name : #GtGitFileCreationPane,
	#superclass : #GtGitMagrittePane,
	#instVars : [
		'filename'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #magritte }
GtGitFileCreationPane >> acceptLabel [
	^ 'Create new file'
]

{ #category : #accessing }
GtGitFileCreationPane >> filename [
	^ filename
]

{ #category : #accessing }
GtGitFileCreationPane >> filename: aString [
	filename := aString
]

{ #category : #magritte }
GtGitFileCreationPane >> filenameDescription [
	<magritteDescription>
	^ MAStringDescription new
		priority: 3;
		label: 'File name';
		accessor: #filename;
		default: '';
		beRequired;
		addCondition: [ :aValue | aValue trimBoth isNotEmpty ]
			labelled: 'Filename must be non empty'
]

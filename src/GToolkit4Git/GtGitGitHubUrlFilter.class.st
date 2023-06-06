"
Convert GitHub issue links like [](https://github.com/feenkcom/gtoolkit/issues/3298) into `[feenkcom/gtoolkit#3298]` strings.
"
Class {
	#name : #GtGitGitHubUrlFilter,
	#superclass : #BrTextEditorInputFilter,
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitGitHubUrlFilter >> filter: aString [
	<return: #String>
	| aRegex anOrganization aRepository anIssue |
	aRegex := '^https?\://github.com/([^/]+)/([^/]+)/issues/([[:digit:]]+)$' asRegex.

	(aRegex matches: aString) ifFalse: [ ^ aString ].

	anOrganization := aRegex subexpression: 2.
	aRepository := aRegex subexpression: 3.
	anIssue := aRegex subexpression: 4.

	^ String
		streamContents: [ :aStream | 
			aStream
				nextPut: $[;
				nextPutAll: anOrganization;
				nextPut: $/;
				nextPutAll: aRepository;
				nextPut: $#;
				nextPutAll: anIssue;
				nextPut: $] ]
]

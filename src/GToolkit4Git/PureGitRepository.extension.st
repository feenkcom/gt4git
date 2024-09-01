Extension { #name : #PureGitRepository }

{ #category : #'*GToolkit4Git' }
PureGitRepository >> exampleGToolkit [
	<gtExample>
	<noTest>
	
	self location: (IceRepository repositoryNamed: 'gtoolkit') location.
	
	self assert: self exists.
	
	^ self
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> exampleGt4Git [
	<gtExample>
	<noTest>

	self location: (IceRepository repositoryNamed: 'gt4git') location.

	self assert: self exists.

	^ self
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> exampleGt4GitRootCommit [
	<gtExample>
	<noTest>
	
	| rootCommit |

	self exampleGt4Git.

	rootCommit := self resolveCommit: '9cfbcd6a921f237abc14446d565cc440a60793e8'. 

	self assert: rootCommit isRoot.
	self assert: rootCommit id = '9cfbcd6a921f237abc14446d565cc440a60793e8'.
	self assert: rootCommit commitId = '9cfbcd6a921f237abc14446d565cc440a60793e8'.
	self assert: rootCommit author = 'George Ganea'.
	self assert: (rootCommit comment includesSubstring: 'created a new repo').

	^ rootCommit
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtDetails [
	^ {
		{ 'location' . self location ifNil: [ 'not set' ] . self location }.
		{ 'exists' . self exists }
	}
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ self gtDetails ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtLogFor: composite [
	<gtView>
	
	^ composite columnedList
		title: 'Log';
		priority: 30;
		items: [ self log ];
		column: 'Commit' text: [ :commit | commit id ];
		column: 'Timestamp' text: [ :commit | commit timestamp ];
		column: 'Author' text: [ :commit | commit author ];
		column: 'Comment' text: [ :commit | commit comment ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtTagsFor: composite [
	<gtView>
	
	^ composite columnedList
		title: 'Tags';
		priority: 40;
		items: [ self tags ];
		column: 'Name' text: [ :tag | tag name ];
		column: 'Commit' text: [ :tag | tag commitId ]
]

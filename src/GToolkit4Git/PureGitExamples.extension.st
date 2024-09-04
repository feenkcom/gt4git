Extension { #name : #PureGitExamples }

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleGToolkit [
	<gtExample>
	<noTest>

	| repository |

	repository := PureGitRepository on: (IceRepository repositoryNamed: 'gtoolkit') location.

	self assert: repository exists.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleGt4Git [
	<gtExample>
	<noTest>

	| repository |

	repository := PureGitRepository on: (IceRepository repositoryNamed: 'gt4git') location.

	self assert: repository exists.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleGt4GitLogHead [
	<gtExample>
	<noTest>

	| repository commit events |

	IceGitCliPlatform current signalClass: GtGitCliSignal.
	GtGitCliSignal memoryLogger reset.
	
	repository := self exampleGt4Git.
	
	commit := repository head.

	self assert: GtGitCliSignal memoryLogger recordings isNotEmpty.
	events := GtGitCliSignal groupedEvents.

	^ events
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleGt4GitRootCommit [
	<gtExample>
	<noTest>
	
	| repository rootCommit |

	repository := self exampleGt4Git.

	rootCommit := repository resolveCommit: '9cfbcd6a921f237abc14446d565cc440a60793e8'. 

	self assert: rootCommit isRoot.
	self assert: rootCommit id = '9cfbcd6a921f237abc14446d565cc440a60793e8'.
	self assert: rootCommit commitId = '9cfbcd6a921f237abc14446d565cc440a60793e8'.
	self assert: rootCommit author = 'George Ganea'.
	self assert: (rootCommit comment includesSubstring: 'created a new repo').

	^ rootCommit
]

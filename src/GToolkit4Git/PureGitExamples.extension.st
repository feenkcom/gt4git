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

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleInitializedRepository [
	<gtExample>
	<noTest>
	
	| repository |
	
	repository := self exampleNonExistingRepository.

	repository init.

	self assert: repository exists.
	self assert: repository hasHead not.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleNonExistingRepository [
	<gtExample>
	<noTest>
	
	| randomName location repository |
	
	randomName := 'repo-' , 999 atRandom asString.

	location := FileLocator temp / randomName.
	
	repository := PureGitRepository on: location.

	self assert: repository exists not.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleSvcDemo [
	<gtExample>
	<noTest>

	| repository |

	repository := PureGitRepository on: FileLocator temp / 'svc-demo'.

	repository location exists
		ifTrue: [ repository location deleteAll ].

	repository clone: 'git@github.com:svenvc/svc-demo.git'.

	self assert: repository exists.
	self assert: repository hasHead.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleSvcDemoEmptyFileCommit [
	<gtExample>
	<noTest>

	| repository commit tree docTree emptyEntry emptyBlob |

	repository := self exampleSvcDemo.

	commit := repository log 
			detect: [ :each | each timestamp asBeginOfDay = '2024-09-05' asZTimestamp ].

	self assert: commit comment = 'Added an empty file'.

	tree := commit tree.
	docTree := (tree entryNamed: 'doc') resolve.
	emptyEntry := docTree entryNamed: 'empty'.
	emptyBlob := emptyEntry resolve.

	self assert: emptyEntry id = (PureGitBlob hashText: String empty) hex.
	self assert: emptyBlob text = String empty.

	^ commit
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleSvcDemoTestCommit [
	<gtExample>
	<noTest>

	| repository commit parentCommit tree parentTree entry parentEntry docTree parentDocTree diff |

	repository := self exampleSvcDemo.

	commit := repository log
		detect: [ :each | each timestamp asBeginOfDay = '2024-09-06' asZTimestamp ].

	self assert: commit comment lines first = 'test commit'.

	parentCommit := commit parent.

	tree := commit tree.
	parentTree := parentCommit tree.

	"only the 4th entry, doc, changed"
	#(1 2 3 5) do: [ :index |
		entry := tree entries at: index.
		parentEntry := parentTree entries at: index.
		self assert: entry name = parentEntry name.
		self assert: entry id = parentEntry id ].
	entry := tree entries fourth.
	parentEntry := parentTree entries fourth.
	self assert: entry name = 'doc'.
	self assert: entry name = parentEntry name.
	self assert: entry id ~= parentEntry id.

	docTree := entry resolve.
	parentDocTree := parentEntry resolve.

	"glider.jpg is unchanged & identical"
	self assert: (docTree entryNamed: 'glider.jpg') id = (parentDocTree entryNamed: 'glider.jpg') id.
	"empty was deleted"
	self assert: (docTree hasEntryNamed: 'empty') not.
	self assert: (parentDocTree hasEntryNamed: 'empty').
	"test.txt was added"
	self assert: (docTree hasEntryNamed: 'test.txt').
	self assert: (parentDocTree hasEntryNamed: 'test.txt') not.
	"NOTES.md was changed"
	self assert: (docTree entryNamed: 'NOTES.md') id ~= (parentDocTree entryNamed: 'NOTES.md') id.
	
	diff := GtDiffBuilder
		computeDifferencesFrom: (String cr join: parentTree flatPaths)
		to: (String cr join: tree flatPaths)
		using: GtLineDiffSplitter ignoringEOLChars.

	self assert: diff changes size = 2.
	self assert: diff changes first isReplacement.
	self assert: diff changes second isInsertion.

	diff := GtDiffBuilder
		computeDifferencesFrom: parentTree flatPaths
		to: tree flatPaths
		using: GtNullDiffSplitter new.

	self assert: diff changes size = 2.
	self assert: diff changes first isReplacement.
	self assert: diff changes second isInsertion.

	entry := docTree entryNamed: 'test.txt'.
	self assert: entry id = (PureGitBlob hashText: 'what is up, doc?') hex.
	self assert: entry resolve text = 'what is up, doc?'.

	entry := docTree entryNamed: 'NOTES.md'.
	parentEntry := parentDocTree entryNamed: 'NOTES.md'.

	diff := GtDiffBuilder
		computeDifferencesFrom: entry resolve text 
		to: parentEntry resolve text
		using: GtLineDiffSplitter ignoringEOLChars.

	self assert: diff changes size = 2.
	self assert: diff changes first isReplacement.
	self assert: diff changes second isDeletion.

	^ commit
]

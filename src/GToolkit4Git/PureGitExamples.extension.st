Extension { #name : #PureGitExamples }

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleAnatomyOfACommit [
	<gtExample>
	<noTest>
	
	| repository commit tree entry blob parent parentBlob changes |

	repository := self exampleSecondCommitInRepository.

	self
		assert: (repository location / self exampleFilename) contents
		equals: self exampleFileContentsChanged.

	commit := repository head.
	tree := commit tree.
	entry := tree entryNamed: self exampleFilename.
	blob := entry resolve.

	self assert: commit comment equals: self exampleSecondCommitComment.
	self assert: blob text equals: self exampleFileContentsChangedInRepository.
	self 
		assert: blob id
		equals: (PureGitBlob hashText: self exampleFileContentsChangedInRepository).
	
	self assert: commit hasSingleParent.

	parent := commit parent.
	parentBlob := (parent tree entryNamed: self exampleFilename) resolve.

	self assert: commit id ~= parent id.
	self assert: blob id ~= parentBlob id.
	self assert: parentBlob text equals: self exampleFileContentsInRepository.

	changes := commit changesToParent.

	self assert: changes diffs size equals: 1.
	self assert: changes firstDiff numberOfLinesAdded equals: 1.
	self assert: changes firstDiff numberOfLinesRemoved equals: 0.
	self
		assert: changes firstDiff changeChunks first oldContents lines
		equals: self exampleFileContents lines.
	self
		assert: changes firstDiff changeChunks first newContents lines
		equals: self exampleFileContentsChanged lines.

	^ commit
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleChangedStagedTrackedFileInRepository [
	<gtExample>
	<noTest>

	| repository fileStatuses |

	repository := self exampleChangedTrackedFileInRepository.

	repository operations stage: self exampleFilename.

	fileStatuses := repository status.
	self assert: fileStatuses size = 1.
	self assert: fileStatuses first path = self exampleFilename.
	self assert: fileStatuses first statusInWorkTree = #unmodified.
	self assert: fileStatuses first statusInIndex = #modified.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleChangedTrackedFileInRepository [
	<gtExample>
	<noTest>

	| repository fileStatuses |

	repository := self exampleFirstCommitInRepository.

	(repository location / self exampleFilename) writeStreamDo: [ :out |
		out nextPutAll: self exampleFileContentsChanged ].

	fileStatuses := repository status.
	self assert: fileStatuses size = 1.
	self assert: fileStatuses first path = self exampleFilename.
	self assert: fileStatuses first statusInWorkTree = #modified.
	self assert: fileStatuses first statusInIndex = #unmodified.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleContentAddressableObjectStore [
	<gtExample>
	<noTest>

	| repository id blob idChanged blobChanged |

	repository := self exampleSecondCommitInRepository.

	id := PureGitBlob hashText: self exampleFileContentsInRepository.

	self assert: id isString.
	self assert: id size equals: 40.
	self assert: (id allSatisfy: [ :each | '0123456789abcdef' includes: each ]).

	blob := repository resolveBlob: id.

	self assert: blob id equals: id.
	self assert: blob text equals: self exampleFileContentsInRepository.

	idChanged := PureGitBlob hashText: self exampleFileContentsChangedInRepository.
	blobChanged := repository resolveBlob: idChanged.

	self assert: blobChanged id equals: idChanged.
	self assert: blobChanged text equals: self exampleFileContentsChangedInRepository.

	self assert: id ~= idChanged.
	self assert: blob contents ~= blobChanged contents.

	self
		assert: (repository location / self exampleFilename) contents
		equals: self exampleFileContentsChanged.

	^ Array with: blob with: blobChanged
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleDetachedHead [
	<gtExample>
	<noTest>

	| repository head branch parent |

	repository := self exampleSecondCommitInRepository.

	head := repository head.
	branch := repository branch.

	self assert: repository hasDetachedHead not.
	self assert: head equals: branch commit.
	self 
		assert: (repository location / self exampleFilename) contents
		equals: self exampleFileContentsChanged.

	parent := head parent.

	parent checkout.

	self assert: repository hasDetachedHead.
	self assert: repository head equals: parent.
	self assert: repository branch isNil.
	self 
		assert: (repository location / self exampleFilename) contents
		equals: self exampleFileContents.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleFileContents [
	<gtExample>

	^ String streamContents: [ :out |
		(ZnNewLineWriterStream on: out)
			forPlatformLineEnding;
			<< 'Sic mundus creatus est.'; newLine ]
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleFileContentsChanged [
	<gtExample>

	^ String streamContents: [ :out |
		(ZnNewLineWriterStream on: out)
			forPlatformLineEnding;
			<< 'Sic mundus creatus est.'; newLine;
			<< 'Anno MMXXIV'; newLine ]
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleFileContentsChangedInRepository [
	<gtExample>

	| autoCrLf |
	autoCrLf := self currentIceGitCliPlatform config
			at: 'core.autocrlf'
			ifAbsent: [ 'false' ].
	^ autoCrLf = 'false'
		ifTrue: [ self exampleFileContentsChanged ]
		ifFalse: [ String streamContents: [ :out | 
					(ZnNewLineWriterStream on: out)
						forLf;
						nextPutAll: self exampleFileContentsChanged ] ]
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleFileContentsInRepository [
	<gtExample>

	| autoCrLf |
	autoCrLf := self currentIceGitCliPlatform config
			at: 'core.autocrlf'
			ifAbsent: [ 'false' ].
	^ autoCrLf = 'false'
		ifTrue: [ self exampleFileContents ]
		ifFalse: [ String streamContents: [ :out | 
					(ZnNewLineWriterStream on: out)
						forLf;
						nextPutAll: self exampleFileContents ] ]
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleFileHistory [
	<gtExample>
	<noTest>

	| repository path gitFile log lastCommit reconstructedContents fileContents |

	repository := self exampleGt4Git.

	path := 'src/GToolkit4Git/GtGitRepository.class.st'.

	gitFile := repository resolveFilePath: path.

	self assert: gitFile exists.

	log := gitFile log toArray wait.

	lastCommit := log first.

	self assert: lastCommit path equals: path.

	self assert: log size < repository log size wait.

	self assert: lastCommit contents equals: gitFile contents.

	self assert: lastCommit contentsByFilesystem equals: gitFile contents.

	reconstructedContents := (gitFile logPatchReverse
		inject: String empty
		into: [ :contents :extendedFileCommit |
			extendedFileCommit changesToParent applyTo: contents ]) wait.

	fileContents := String streamContents: [ :out |
		gitFile contents linesDo: [ :line | out nextPutAll: line; cr ] ].

	self 
		assert: reconstructedContents 
		equals: fileContents.

	^ gitFile
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleFilename [
	^ 'file-1.txt'
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleFirstCommitComment [
	^ 'First commit'
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleFirstCommitInRepository [
	<gtExample>
	<noTest>
	
	| repository head entry |
	
	repository := self exampleNewStagedFileInRepository.

	repository operations commit: self exampleFirstCommitComment.

	self assert: repository status isEmpty.

	head := repository head.

	self assert: head comment equals: self exampleFirstCommitComment.
	self assert: head numberOfParents equals: 0.
	self assert: head hasParents not.
	self assert: head isRoot.

	entry := head tree entries first.
	
	self assert: entry name equals: self exampleFilename.
	self assert: entry resolve text equals: self exampleFileContentsInRepository.
	self assert: entry id equals: (PureGitBlob hashText: self exampleFileContentsInRepository).

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleFixDetachedHead [
	<gtExample>
	<noTest>

	| repository initialDefaultBranchName branch |

	repository := self exampleDetachedHead.

	initialDefaultBranchName := repository queries initialDefaultBranchName.

	branch := repository queries localBranches 
		detect: [ :each | each name = initialDefaultBranchName ].

	branch checkout.

	self assert: repository hasDetachedHead not.
	self assert: repository head equals: branch commit.
	self assert: repository branch equals: branch.
	self 
		assert: (repository location / self exampleFilename) contents 
		equals: self exampleFileContentsChanged.

	^ repository
]

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

	rootCommit := repository queries resolveCommit: '9cfbcd6a921f237abc14446d565cc440a60793e8'. 

	self assert: rootCommit isRoot.
	self assert: rootCommit hasParents not.
	self assert: rootCommit id equals: '9cfbcd6a921f237abc14446d565cc440a60793e8'.
	self assert: rootCommit commitId equals: '9cfbcd6a921f237abc14446d565cc440a60793e8'.
	self assert: rootCommit author equals: 'George Ganea'.
	self assert: (rootCommit comment includesSubstring: 'created a new repo').

	^ rootCommit
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleIcebergGitCli [
	<gtExample>
	<noTest>

	| workingDirectory gitUrl repository |

	workingDirectory := FileLocator temp resolve / 'example-clone'.
	workingDirectory exists ifTrue: [ workingDirectory deleteAll ].

	gitUrl := PureGitUrl with: 'git@github.com:feenkcom/iceberg-git-cli.git'.

	self assert: gitUrl isScpUrl.
	self assert: gitUrl ownerName equals: 'feenkcom'.
	self assert: gitUrl repositoryName equals: 'iceberg-git-cli'.

	repository := gitUrl cloneWithOwnerPrefixIn: workingDirectory.

	self 
		assert: repository location 
		equals: workingDirectory / gitUrl ownerName / gitUrl repositoryName.

	self assert: repository exists.
	self assert: repository hasHead.
	self assert: repository branch upstream remote url equals: gitUrl url.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleInitializedRepository [
	<gtExample>
	<noTest>
	
	| repository |
	
	repository := self exampleNonExistingRepository.

	repository operations init.

	self assert: repository exists.
	self assert: repository hasHead not.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleNewStagedFileInRepository [
	<gtExample>
	<noTest>
	
	| repository fileStatuses |
	
	repository := self exampleNewUntrackedFileInRepository.

	fileStatuses := repository status.

	repository operations stage: fileStatuses first path.

	fileStatuses := repository status.

	self assert: fileStatuses size equals: 1.
	self assert: fileStatuses first path equals: self exampleFilename.
	self assert: fileStatuses first statusInWorkTree equals: #unmodified.
	self assert: fileStatuses first statusInIndex equals: #added.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleNewUntrackedFileInRepository [
	<gtExample>
	<noTest>

	| repository fileStatuses |

	repository := self exampleInitializedRepository.

	(repository location / self exampleFilename) writeStreamDo: [ :out |
		out nextPutAll: self exampleFileContents ].

	fileStatuses := repository status.
	self assert: fileStatuses size equals: 1.
	self assert: fileStatuses first path equals: self exampleFilename.
	self assert: fileStatuses first statusInWorkTree equals: #unknown.
	self assert: fileStatuses first statusInIndex equals: #unknown.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleNonExistingRepository [
	<gtExample>
	<noTest>

	| randomName location repository |

	randomName := 'repo-' , 999 atRandom asString.

	location := FileLocator temp / randomName.

	location exists ifTrue: [ location ensureDeleteAll ].

	repository := PureGitRepository on: location.

	self assert: repository exists not.

	^ repository
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleSecondCommitComment [
	^ 'Second commit'
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleSecondCommitInRepository [
	<gtExample>
	<noTest>
	
	| repository head entry |
	
	repository := self exampleChangedStagedTrackedFileInRepository.

	repository operations commit: self exampleSecondCommitComment.

	self assert: repository status isEmpty.

	head := repository head.

	self assert: head comment equals: self exampleSecondCommitComment.
	self assert: head hasSingleParent.
	self assert: head hasParents.
	self assert: head parent comment equals: self exampleFirstCommitComment.

	entry := head tree entries first.
	
	self assert: entry name equals: self exampleFilename.
	self assert: entry resolve text equals: self exampleFileContentsChangedInRepository.
	self assert: entry id equals: (PureGitBlob hashText: self exampleFileContentsChangedInRepository).

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

	repository operations clone: 'git@github.com:svenvc/svc-demo.git'.

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

	commit := (repository log 
			select: [ :each | each timestamp asBeginOfDay = '2024-09-05' asZTimestamp ]) next wait value.

	self assert: commit comment = 'Added an empty file'.

	tree := commit tree.
	docTree := (tree entryNamed: 'doc') resolve.
	emptyEntry := docTree entryNamed: 'empty'.
	emptyBlob := emptyEntry resolve.

	self assert: emptyEntry id = (PureGitBlob hashText: String empty).
	self assert: emptyBlob text = String empty.

	^ commit
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleSvcDemoIncrementalHistoryContentsReconstruction [
	<gtExample>
	<noTest>

	| repository gitDirectory gitFiles |

	repository := self exampleSvcDemo.

	gitDirectory := repository resolveDirectoryPath: 'src/SvcDemo'.

	gitFiles := gitDirectory children select: [ :each |
		'*.class.st' match: each path  ].

	gitFiles do: [ :each |
		each validateIncrementalHistoryContentsReconstruction ].

	^ gitFiles
]

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleSvcDemoTestCommit [
	<gtExample>
	<noTest>

	| repository commit parentCommit tree parentTree entry parentEntry docTree parentDocTree diff |

	repository := self exampleSvcDemo.

	commit := (repository log
		select: [ :each | each timestamp asBeginOfDay = '2024-09-06' asZTimestamp ]) next wait value.

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
	self assert: entry id = (PureGitBlob hashText: 'what is up, doc?').
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

{ #category : #'*GToolkit4Git' }
PureGitExamples >> exampleUnstageFileInRepository [
	<gtExample>
	<noTest>

	| repository fileStatuses |

	repository := self exampleFirstCommitInRepository.

	(repository location / 'extra.txt') writeStreamDo: [ :out | out print: 42 ].

	repository operations stage: 'extra.txt'.

	fileStatuses := repository status.

	self assert: fileStatuses isEmpty not.
	self assert: fileStatuses first path equals: 'extra.txt'.
	self assert:  fileStatuses first statusInIndex equals: #added.

	repository operations unstage: 'extra.txt'.

	fileStatuses := repository status.

	self assert: fileStatuses isEmpty not.
	self assert: fileStatuses first path equals: 'extra.txt'.
	self assert:  fileStatuses first statusInIndex equals: #unknown.

	(repository location / 'extra.txt') delete.

	fileStatuses := repository status.

	self assert: fileStatuses isEmpty.

	^ repository
]

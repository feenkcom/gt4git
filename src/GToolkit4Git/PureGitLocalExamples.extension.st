Extension { #name : #PureGitLocalExamples }

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> baseDirectory [
	<gtExample>
	
	^ (FileLocator temp / self class name) ensureCreateDirectory
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> cloneRepositoryAIntoRepositoryB [
	<gtExample>
	<noTest>

	| repositoryAUrl numberFile |

	self repositoryBLocation exists 
		ifTrue: [ self repositoryBLocation deleteAll ].

	repositoryA := self firstCommitInRepositoryA.

	repositoryAUrl := repositoryA location resolve asUrl.

	repositoryB := PureGitRepository on: self repositoryBLocation.

	repositoryB operations clone: repositoryAUrl printString.

	numberFile := repositoryB location / 'number.txt'.

	self assert: numberFile exists.
	self assert: numberFile contents lines first = '1. first'.
	self assert: repositoryA head comment = 'First commit'.

	^ repositoryB
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> firstCommitInRepositoryA [
	<gtExample>
	<noTest>

	| numberFile |

	repositoryA := self initRepositoryA.

	numberFile := repositoryA location / 'number.txt'.

	numberFile writeStreamDo: [ :out | 
		(ZnNewLineWriterStream on: out)
			forPlatformLineEnding;
			<< '1. first'; newLine ].

	repositoryA operations stage: numberFile basename.

	repositoryA operations commit: 'First commit'.

	self assert: repositoryA branch name = repositoryA queries initialDefaultBranchName.
	self assert: repositoryA head comment = 'First commit'.

	^ repositoryA
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'repository A' . repositoryA }.
			{ 'repository B' . repositoryB }.
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> initRepositoryA [
	<gtExample>
	<noTest>

	self repositoryALocation exists 
		ifTrue: [ self repositoryALocation deleteAll ].

	repositoryA := PureGitRepository on: self repositoryALocation.

	repositoryA operations init.

	self assert: repositoryA exists.
	self assert: repositoryA location equals: self repositoryALocation.
	self assert: repositoryA hasHead not.
	self assert: repositoryA branch isNil.
	self assert: repositoryA queries allBranches isEmpty.
	self assert: repositoryA queries tags toArray wait isEmpty.
	self assert: repositoryA queries remotes isEmpty.

	^ repositoryA
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> pullRepositoryAToRepositoryB [
	<gtExample>
	<noTest>

	| numberFile |

	self thirdCommitInRepositoryA.
	
	repositoryB branch upstream remote pull.
	
	numberFile := repositoryB location / 'number.txt'.

	self assert: numberFile contents lines first = '3. third'.
	self assert: repositoryB head comment = 'Third commit'.

	self assert: repositoryA head = repositoryB head. 

	^ repositoryB
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> pushRepositoryBToRepositoryA [
	<gtExample>
	<noTest>

	| numberFile |

	repositoryB := self secondCommitInRepositoryB.

	"self assert: repositoryB queries outgoingCommits isEmpty not."

	repositoryA operations createBranch: 'branch-temporary'. "git won't push into local remote when branch is the same"

	repositoryB branch upstream remote push.

	"self assert: repositoryB queries outgoingCommits isEmpty."

	repositoryA operations checkout: repositoryA queries initialDefaultBranchName.

	numberFile := repositoryA location / 'number.txt'.

	self assert: numberFile contents lines first = '2. second'.
	self assert: repositoryA branch commit comment trimBoth = 'Second commit'.

	self assert: repositoryA head = repositoryB head.

	^ self
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> repositoryALocation [
	^ self baseDirectory / self repositoryAName
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> repositoryAName [
	^ 'RepositoryA'
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> repositoryBLocation [
	^ self baseDirectory / self repositoryBName
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> repositoryBName [
	^ 'RepositoryB'
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> secondCommitInRepositoryB [
	<gtExample>
	<noTest>

	| numberFile |

	repositoryB := self cloneRepositoryAIntoRepositoryB.

	numberFile := repositoryB location / 'number.txt'.

	numberFile writeStreamDo: [ :out |
		out truncate.
		(ZnNewLineWriterStream on: out)
			forPlatformLineEnding;
			<< '2. second'; newLine ].

	repositoryB operations stage: numberFile basename.

	repositoryB operations commit: 'Second commit'.

	self assert: repositoryB branch name = repositoryA queries initialDefaultBranchName.
	self assert: repositoryB head comment = 'Second commit'.

	^ repositoryB
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> thirdCommitInRepositoryA [
	<gtExample>
	<noTest>

	| numberFile |

	self pushRepositoryBToRepositoryA.

	numberFile := repositoryA location / 'number.txt'.

	numberFile writeStreamDo: [ :out |
		out truncate.
		(ZnNewLineWriterStream on: out)
			forPlatformLineEnding;
			<< '3. third'; newLine ].

	repositoryA operations stage: numberFile basename.

	repositoryA operations commit: 'Third commit'.

	self assert: repositoryA head comment = 'Third commit'.

	^ repositoryA
]

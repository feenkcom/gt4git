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
	self assert: numberFile contents lines first equals: '1. first'.
	self assert: repositoryB head comment equals: 'First commit'.

	self assert: repositoryA head equals: repositoryB head.
	self assert: repositoryA branch equals: repositoryB branch.

	^ repositoryB
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> fetchRepositoryAToRepositoryB [
	<gtExample>
	<noTest>

	self thirdCommitInRepositoryA.

	repositoryB branch upstream remote fetch.

	self assert: repositoryB branch incomingCommits hasNext wait.

	^ self
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

	self assert: repositoryA hasHead.
	self assert: repositoryA branch name equals: repositoryA queries initialDefaultBranchName.
	self assert: repositoryA head comment equals: 'First commit'.

	^ repositoryA
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> fourthCommitInBranchInRepositoryA [
	<gtExample>
	<noTest>

	| numberFile originalBranch |

	repositoryA := self thirdCommitInRepositoryA.
	
	originalBranch := repositoryA branch.

	repositoryA operations createBranch: 'feature-1'.

	self assert: repositoryA branch name equals: 'feature-1'.

	numberFile := repositoryA location / 'number.txt'.

	numberFile writeStreamDo: [ :out |
		out truncate.
		(ZnNewLineWriterStream on: out)
			forPlatformLineEnding;
			<< '4. fourth'; newLine ].

	repositoryA operations stage: numberFile basename.

	repositoryA operations commit: 'Fourth commit'.

	self assert: repositoryA head comment equals: 'Fourth commit'.
	self assert: repositoryA head equals: repositoryA branch commit.
	self assert: repositoryA head parent equals: originalBranch commit.

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
	self assert: repositoryA queries tags hasNext wait not.
	self assert: repositoryA queries remotes isEmpty.

	^ repositoryA
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> mergeBranchInRepositoryA [
	<gtExample>
	<noTest>

	| numberFile featureBranch initialBranch initialDefaultBranchName |

	repositoryA := self fourthCommitInBranchInRepositoryA.

	numberFile := repositoryA location / 'number.txt'.

	self assert: numberFile contents lines first equals: '4. fourth'.

	featureBranch := repositoryA branch.

	self assert: featureBranch name equals: 'feature-1'.
	self assert: featureBranch commit equals: repositoryA head.

	initialDefaultBranchName := repositoryA queries initialDefaultBranchName.
	initialBranch := repositoryA queries localBranches
		detect: [ :each | each name = initialDefaultBranchName ].

	initialBranch checkout.

	self assert: numberFile contents lines first equals: '3. third'.
	self assert: initialBranch commit equals: repositoryA head.

	featureBranch merge.

	initialBranch := repositoryA queries localBranches
		detect: [ :each | each name = initialDefaultBranchName ].
	featureBranch := repositoryA queries localBranches
		detect: [ :each | each name = 'feature-1' ].

	self assert: initialBranch commit equals: featureBranch commit.
	self assert: initialBranch equals: repositoryA branch.
	self assert: featureBranch commit equals: repositoryA branch commit.

	self assert: numberFile contents lines first equals: '4. fourth'.

	^ repositoryA
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> pullRepositoryAToRepositoryB [
	<gtExample>
	<noTest>

	| numberFile |

	self thirdCommitInRepositoryA.
	
	repositoryB branch upstream remote pull.

	self assert: repositoryB branch incomingCommits hasNext wait not.

	numberFile := repositoryB location / 'number.txt'.

	self assert: numberFile contents lines first equals: '3. third'.
	self assert: repositoryB head comment equals: 'Third commit'.

	self assert: repositoryA head equals: repositoryB head.
	self assert: repositoryA branch equals: repositoryB branch.

	^ self
]

{ #category : #'*GToolkit4Git' }
PureGitLocalExamples >> pushRepositoryBToRepositoryA [
	<gtExample>
	<noTest>

	| numberFile |

	repositoryB := self secondCommitInRepositoryB.

	self assert: repositoryB branch outgoingCommits hasNext wait.

	repositoryA operations createBranch: 'temporary'. "git won't push into local remote when branch is the same"

	repositoryB branch upstream remote push.

	self assert: repositoryB branch outgoingCommits hasNext wait not.

	repositoryA operations checkout: repositoryA queries initialDefaultBranchName.

	numberFile := repositoryA location / 'number.txt'.

	self assert: numberFile contents lines first equals: '2. second'.
	self assert: repositoryA branch commit comment trimBoth equals: 'Second commit'.

	self assert: repositoryA head equals: repositoryB head.
	self assert: repositoryA branch equals: repositoryB branch.

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

	self assert: repositoryB branch name equals: repositoryA queries initialDefaultBranchName.
	self assert: repositoryB head comment equals: 'Second commit'.

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

	self assert: repositoryA head comment equals: 'Third commit'.

	^ repositoryA
]

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

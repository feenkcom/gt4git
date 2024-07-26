Class {
	#name : #IceGitCliLocalRepositoryExamples,
	#superclass : #Object,
	#instVars : [
		'repositoryA',
		'repositoryB'
	],
	#category : #'GToolkit4Git-Examples'
}

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> baseDirectory [
	^ (FileLocator temp / self class name) ensureCreateDirectory
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> cloneRepositoryAIntoRepositoryB [
	<gtExample>
	<noTest>
	
	| repositoryAUrl numberFile |
	
	self repositoryBLocation exists 
		ifTrue: [ self repositoryBLocation deleteAll ].

	repositoryA := self firstCommitInRepositoryA.

	repositoryAUrl := repositoryA location resolve asUrl.
	
	repositoryB := GtIceRepositoryCreator new
		location: self repositoryBLocation;
		url: repositoryAUrl asString;
		cloneRepository.

	repositoryB name: self repositoryBName.

	numberFile := repositoryB location / 'number.txt'.
	
	self assert: numberFile exists.
	self assert: numberFile contents trimBoth = '1. first'.
	self assert: repositoryA head commits first comment trimBoth = 'First commit'.

	^ repositoryB
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> defaultBranchName [
	<gtExample>
	<noTest>
	
	^ IceGitCliPlatform current config
		at: 'init.defaultbranch'
		ifAbsent: [ 'master' ]
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> firstCommitInRepositoryA [
	<gtExample>
	<noTest>

	| numberFile workingCopy |

	repositoryA := self initRepositoryA.

	numberFile := repositoryA location / 'number.txt'.

	numberFile writeStreamDo: [ :out | 
		(ZnNewLineWriterStream on: out) << '1. first'; cr ].

	repositoryA addFileToIndex: numberFile basename.

	workingCopy := repositoryA workingCopy.

	workingCopy
		commitChanges: workingCopy diffToReferenceCommit 
		withMessage: 'First commit' 
		force: true.

	self assert: repositoryA head name = self defaultBranchName.
	self assert: repositoryA localBranches first name = self defaultBranchName.
	self assert: repositoryA head commits first comment trimBoth = 'First commit'.

	^ repositoryA
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> gitVersion [
	<gtExample>
	<noTest>
	
	| versionString gitVersion major minor |

	versionString := IceGitCliPlatform current gitVersion.
	gitVersion := (Character space split: versionString) third.
	major := ($. split: gitVersion) first asInteger.
	minor := ($. split: gitVersion) second asInteger.
	self
		assert: (major > 2 or: [ major = 2 and: [ minor >= 26 ] ])
		description: 'git version should be >= 2.26'.

	^ versionString
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> initRepositoryA [
	<gtExample>
	<noTest>

	self repositoryALocation exists 
		ifTrue: [ self repositoryALocation deleteAll ].

	repositoryA := GtIceRepositoryCreator new
		location: self repositoryALocation;
		createNewRepositoryNamed: self repositoryAName.

	self assert: repositoryA isValid.
	self assert: repositoryA location = self repositoryALocation.
	self assert: repositoryA head commits isEmpty.
	self assert: repositoryA localBranches isEmpty.
	self assert: repositoryA remoteTrackedBranches isEmpty.

	^ repositoryA
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> mergeRepositoryAIntoRepositoryBAndPush [
	<gtExample>
	<noTest>

	| datefile workingCopy |

	self thirdCommitInRepositoryA.
	
	"A is now one commit ahead of B, we do not pull but make a fourth commit in B"

	datefile := repositoryB location / 'date.txt'.

	datefile writeStreamDo: [ :out | 
		(ZnNewLineWriterStream on: out) << DateAndTime now asString; cr ].

	repositoryB addFileToIndex: datefile basename.

	workingCopy := repositoryB workingCopy.

	workingCopy
		commitChanges: workingCopy diffToReferenceCommit 
		withMessage: 'Fourth commit' 
		force: true.
		
	"A and B are now on different commits and we cannot push"
	
	(repositoryA branchNamed: 'branch-temporary') switch.

	self assert: ([ repositoryB push. #succeeded ] on: Error do: [ #failed ]) = #failed.

	"First we have to do a pull to merge"
	
	"repositoryB pull." (GtGitRepository fromIcebergRepository: repositoryB) gtLepiterAwarePull.

	self assert: (repositoryB headCommit comment includesSubstring: 'Merge').
	self assert: repositoryB headCommit ancestorIds size > 1.

	"Now we can push our outgoing commits (the fourth and merged commit)"
	
	self assert: repositoryB outgoingCommits size > 1.

	repositoryB push.

	repositoryA switchToBranchNamed: self defaultBranchName.

	^ self
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> pullRepositoryAToRepositoryB [
	<gtExample>
	<noTest>

	| numberFile |

	self thirdCommitInRepositoryA.
	
	"repositoryB pull." (GtGitRepository fromIcebergRepository: repositoryB) gtLepiterAwarePull.
	
	numberFile := repositoryB location / 'number.txt'.

	self assert: numberFile contents trimBoth = '3. third'.
	self assert: repositoryB headCommit comment trimBoth = 'Third commit'.

	self assert: repositoryA headCommit id = repositoryB headCommit id. 

	^ repositoryB
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> pushRepositoryBToRepositoryA [
	<gtExample>
	<noTest>

	| numberFile |

	repositoryB := self secondCommitInRepositoryB.

	self assert: repositoryB outgoingCommits isEmpty not.

	repositoryA createBranch: 'branch-temporary'. "git won't push into local remote when branch is the same"

	repositoryB push.

	self assert: repositoryB outgoingCommits isEmpty.

	repositoryA switchToBranchNamed: self defaultBranchName.

	numberFile := repositoryA location / 'number.txt'.

	self assert: numberFile contents trimBoth = '2. second'.
	self assert: repositoryA branch commit comment trimBoth = 'Second commit'.

	self assert: repositoryA headCommit id = repositoryB headCommit id.

	^ self
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryALocation [
	^ self baseDirectory / self repositoryAName
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryAName [
	^ 'RepositoryA'
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryBLocation [
	^ self baseDirectory / self repositoryBName
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> repositoryBName [
	^ 'RepositoryB'
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> secondCommitInRepositoryB [
	<gtExample>
	<noTest>

	| numberFile workingCopy |

	repositoryB := self cloneRepositoryAIntoRepositoryB.

	numberFile := repositoryB location / 'number.txt'.

	numberFile writeStreamDo: [ :out |
		out truncate.
		(ZnNewLineWriterStream on: out) << '2. second'; cr ].

	repositoryB addFileToIndex: numberFile basename.

	workingCopy := repositoryB workingCopy.

	workingCopy
		commitChanges: workingCopy diffToReferenceCommit 
		withMessage: 'Second commit' 
		force: true.

	self assert: repositoryB head name = self defaultBranchName.
	self assert: repositoryB localBranches first name = self defaultBranchName.
	self assert: repositoryB head commits first comment trimBoth = 'Second commit'.

	^ repositoryB
]

{ #category : #accessing }
IceGitCliLocalRepositoryExamples >> thirdCommitInRepositoryA [
	<gtExample>
	<noTest>

	| numberFile workingCopy |

	self pushRepositoryBToRepositoryA.

	numberFile := repositoryA location / 'number.txt'.

	numberFile writeStreamDo: [ :out |
		out truncate.
		(ZnNewLineWriterStream on: out) << '3. third'; cr ].

	repositoryA addFileToIndex: numberFile basename.

	workingCopy := repositoryA workingCopy.

	workingCopy
		commitChanges: workingCopy diffToReferenceCommit 
		withMessage: 'Third commit' 
		force: true.

	self assert: repositoryA headCommit comment trimBoth = 'Third commit'.

	^ repositoryA
]

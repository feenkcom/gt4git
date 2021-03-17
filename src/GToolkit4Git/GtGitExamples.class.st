Class {
	#name : #GtGitExamples,
	#superclass : #Object,
	#category : #'GToolkit4Git-Model'
}

{ #category : #'examples - repositories - model' }
GtGitExamples >> basicRepositoriesElement [
	<gtExample>
	<noTest>
	| anElement |
	anElement := GtGitRepositoriesElement new.
	^ anElement
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> basicRepositoriesModel [
	<gtExample>
	<noTest>
	| aModel |
	aModel := GtGitRepositories new.
	self assert: aModel collection isNotNil.
	self assert: aModel collection isEmpty.
	^ aModel
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> basicRepositoriesTool [
	<gtExample>
	<noTest>
	| aTool |
	aTool := GtGitRepositoriesTool new.
	self assert: aTool repositoriesViewModel isNil.
	^ aTool
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> basicRepositoriesViewModel [
	<gtExample>
	<noTest>
	| aViewModel |
	aViewModel := GtGitRepositoriesViewModel new.
	self assert: aViewModel hasRepositories not.
	^ aViewModel
]

{ #category : #'examples - repository - model' }
GtGitExamples >> basicRepositoryElement [
	<gtExample>
	<noTest>
	| anElement |
	anElement := GtGitRepositoryElement new.
	^ anElement
]

{ #category : #'examples - repository - model' }
GtGitExamples >> basicRepositoryModel [
	<gtExample>
	<noTest>
	| aModel |
	aModel := GtGitRepository new.
	self assert: aModel repository isNil.
	^ aModel
]

{ #category : #'examples - repository - model' }
GtGitExamples >> basicRepositoryViewModel [
	<gtExample>
	<noTest>
	| aViewModel |
	aViewModel := GtGitRepositoryViewModel new.
	self assert: aViewModel hasRepository not.
	^ aViewModel
]

{ #category : #'examples - repository - model' }
GtGitExamples >> mockRepository [
	<gtExample>
	<noTest>
	| aRepository |
	aRepository := IceRepository registry
		detect: [ :eachRepository | 
			eachRepository name = 'gt4git' ]
		ifNone: [ IceLibgitRepository new 
			name: 'gt4git-mock' ].
	self assert: aRepository isNotNil.
	^ aRepository
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> repositoriesElement [
	<gtExample>
	<noTest>
	| anElement aViewModel |
	anElement := self basicRepositoriesElement.
	aViewModel := self repositoriesViewModel.
	anElement repositoriesViewModel: aViewModel.
	self assert: anElement repositoriesViewModel equals: aViewModel.
	^ anElement
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> repositoriesModel [
	<gtExample>
	<noTest>
	| aModel |
	aModel := GtGitRepositories default.
	self assert: aModel collection isNotNil.
	self assert: aModel collection isNotEmpty.
	^ aModel
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> repositoriesTool [
	<gtExample>
	<noTest>
	| aTool aViewModel |
	aTool := self basicRepositoriesTool.
	aViewModel := self repositoriesViewModel.
	aTool repositoriesViewModel: aViewModel.
	self assert: aTool repositoriesViewModel equals: aViewModel.
	^ aTool
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> repositoriesTool_asElement [
	<gtExample>
	<noTest>
	| aTool anElement |
	aTool := self repositoriesTool.
	anElement := aTool asElementDo: [ :e | e ].
	self assert: anElement isNotNil.
	^ anElement
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> repositoriesViewModel [
	<gtExample>
	<noTest>
	| aViewModel aModel |
	aViewModel := self basicRepositoriesViewModel.
	aModel := self repositoriesModel.
	aViewModel repositoriesModel: aModel.
	self assert: aViewModel repositoriesModel equals: aModel.
	^ aViewModel
]

{ #category : #'examples - repository - model' }
GtGitExamples >> repositoryElement [
	<gtExample>
	<noTest>
	| anElement aViewModel |
	anElement := self basicRepositoryElement.
	aViewModel := self repositoryViewModel.
	anElement repositoryViewModel: aViewModel.
	self assert: anElement repositoryViewModel equals: aViewModel.
	^ anElement
]

{ #category : #'examples - repository - model' }
GtGitExamples >> repositoryModel [
	<gtExample>
	<noTest>
	| aModel aRepository |
	aModel := self basicRepositoryModel.
	aRepository := self mockRepository.
	aModel repository: aRepository.
	self assert: aModel repository equals: aRepository.
	^ aModel
]

{ #category : #'examples - repository - model' }
GtGitExamples >> repositoryViewModel [
	<gtExample>
	<noTest>
	| aViewModel aModel |
	aViewModel := self basicRepositoryViewModel.
	aModel := self repositoryModel.
	aViewModel repositoryModel: aModel.
	self assert: aViewModel repositoryModel equals: aModel.
	^ aViewModel
]

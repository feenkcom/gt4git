Class {
	#name : #GtGitExamples,
	#superclass : #Object,
	#category : #'GToolkit4Git-Model'
}

{ #category : #'examples - repositories - model' }
GtGitExamples >> basicRepositoriesElement [
	<gtExample>
	| anElement |
	anElement := GtGitRepositoriesElement new.
	^ anElement
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> basicRepositoriesModel [
	<gtExample>
	| aModel |
	aModel := GtGitRepositories new.
	self assert: aModel collection isNotNil.
	self assert: aModel collection isEmpty.
	^ aModel
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> basicRepositoriesViewModel [
	<gtExample>
	| aViewModel |
	aViewModel := GtGitRepositoriesViewModel new.
	self assert: aViewModel hasRepositories not.
	^ aViewModel
]

{ #category : #'examples - repository - model' }
GtGitExamples >> basicRepositoryModel [
	<gtExample>
	| aModel |
	aModel := GtGitRepository new.
	self assert: aModel repository isNil.
	^ aModel
]

{ #category : #'examples - repository - model' }
GtGitExamples >> mockRepository [
	<gtExample>
	| aRepository |
	aRepository := IceRepository registry
		detect: [ :eachRepository | 
			eachRepository name = 'gt4git' ].
	self assert: aRepository isNotNil.
	^ aRepository
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> repositoriesElement [
	<gtExample>
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
	| aModel |
	aModel := GtGitRepositories default.
	self assert: aModel collection isNotNil.
	self assert: aModel collection isNotEmpty.
	^ aModel
]

{ #category : #'examples - repositories - model' }
GtGitExamples >> repositoriesViewModel [
	<gtExample>
	| aViewModel aModel |
	aViewModel := self basicRepositoriesViewModel.
	aModel := self repositoriesModel.
	aViewModel repositoriesModel: aModel.
	self assert: aViewModel repositoriesModel equals: aModel.
	^ aViewModel
]

{ #category : #'examples - repository - model' }
GtGitExamples >> repositoryModel [
	<gtExample>
	| aModel aRepository |
	aModel := self basicRepositoryModel.
	aRepository := self mockRepository.
	aModel repository: aRepository.
	self assert: aModel repository equals: aRepository.
	^ aModel
]

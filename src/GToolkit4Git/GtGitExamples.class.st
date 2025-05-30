Class {
	#name : #GtGitExamples,
	#superclass : #Object,
	#category : #'GToolkit4Git-Examples'
}

{ #category : #'examples - repository - model' }
GtGitExamples >> basicRepositoryElement [
	<gtExample>
	<return: #GtGitRepositoryElement>
	| anElement |
	anElement := GtGitRepositoryElement new.
	^ anElement
]

{ #category : #'examples - repository - model' }
GtGitExamples >> basicRepositoryModel [
	<gtExample>
	<return: #GtGitRepository>
	| aModel |
	aModel := GtGitRepository new.
	self assert: aModel repository isNil.
	^ aModel
]

{ #category : #'examples - repository - model' }
GtGitExamples >> basicRepositoryViewModel [
	<gtExample>
	<return: #GtGitRepositoryViewModel>
	| aViewModel |
	aViewModel := GtGitRepositoryViewModel new.
	self assert: aViewModel hasRepository not.
	^ aViewModel
]

{ #category : #'examples - repository - model' }
GtGitExamples >> mockRepository [
	<gtExample>
	<return: #IceGitCliRepository>
	| aRepository |
	aRepository := IceRepository registry
			detect: [ :eachRepository | eachRepository name = 'gt4git' ]
			ifNone: [ IceLibgitRepository new name: 'gt4git-mock' ].
	self assert: aRepository isNotNil.
	^ aRepository
]

{ #category : #'examples - repository - model' }
GtGitExamples >> repositoryElement [
	<gtExample>
	<return: #GtGitRepositoryElement>
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
	<return: #GtGitRepository>
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
	<return: #GtGitRepositoryViewModel>
	| aViewModel aModel |
	aViewModel := self basicRepositoryViewModel.
	aModel := self repositoryModel.
	aViewModel repositoryModel: aModel.
	self assert: aViewModel repositoryModel equals: aModel.
	^ aViewModel
]

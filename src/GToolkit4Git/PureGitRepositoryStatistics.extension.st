Extension { #name : #PureGitRepositoryStatistics }

{ #category : #'*GToolkit4Git' }
PureGitRepositoryStatistics >> gtDetails [
	^ super gtDetails , {
		{ 'number of commits'
			. self log size
			. self log }.
		{ 'first commit'
			. self describeTimestamp: self firstCommit timestamp
			. self firstCommit }.
		{ 'last commit'
			. self describeTimestamp: self lastCommit timestamp
			. self lastCommit }.
		{ 'worktree'
			. self worktreeDescription
			. self repository location }.
	}
]

{ #category : #'*GToolkit4Git' }
PureGitRepositoryStatistics >> gtViewContributorsIn: composite [
	<gtView>
	^ composite columnedList
		title: 'Contributors';
		priority: 30;
		items: [ (self log groupedBy: #author) associations sort: [ :each | each value size ] descending ];
		column: 'author' text: [ :each | each key ];
		column: 'number of commits' text: [ :each | each value size ];
		send: #value
]

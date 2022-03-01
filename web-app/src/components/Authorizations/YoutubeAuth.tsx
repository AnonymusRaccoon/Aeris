import { getCookie, sendServiceAuthToken } from "../../utils/utils";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useEffect } from "react";
import { API_ROUTE } from "../..";

export default function GoogleAuth() {
	const [searchParams, setSearchParams] = useSearchParams();
	const navigate = useNavigate();

	const authCode = searchParams.get("code") as string;

	useEffect(() => {
		sendServiceAuthToken(authCode, "/auth/google").then((ok) => {
			navigate('/pipelines');
		});
	}, []);

	return <div />;
}
